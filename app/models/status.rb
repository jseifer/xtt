require 'tinder'

class Status < ActiveRecord::Base
  validate :set_project_from_code
  validates_presence_of :user_id, :message
  validate :times_are_sane
  
  concerns :hacky_date_methods, :filtering
  
  attr_writer :code_and_message
  attr_writer :followup
  attr_reader :active
  
  belongs_to :user
  belongs_to :project
  
  after_create :cache_user_status
  after_create :process_previous
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
  end
  
  def membership
    @membership = (project? ? user.memberships.for(project) : nil) || false unless @membership == false
  end
  
  def code_and_message
    @code ?
      ("@#{@code} #{message}") :
      (membership ? "@#{membership.code} #{message}" : message)
  end

  def followup(reload = false)
    @followup   = nil if reload
    @followup ||= user.statuses.after(self) || :false
    @followup == :false ? nil : @followup
  end
  
  def previous(reload = false)
    @previous   = nil if reload
    @previous ||= user.statuses.before(self) || :false
    @previous == :false ? nil : @previous
  end
  
  def active?
    @active ||= followup.nil?
  end
  
  def out?
    !project?
  end
  
  def project?
    !project_id.nil?
  end

  def editable_by?(user)
    user &&
      (user.admin?         ||
      (user_id == user.id) || # status owner
      (project? && project.owned_by?(user))) # project owner
  end
  
  def code_and_message=(value)
    @code, self.message = extract_code_and_message(value)
  end

protected
  def set_project_from_code
    unless new_record? && project?
      self.project = @code.blank? ? nil : user.projects.find(:first, :conditions => ['memberships.code = ?', @code])
      if !project? && !@code.blank?
        errors.add_to_base("Invalid project code: @#{@code}")
      end
    end
  end

  def extract_code_and_message(message)
    code = nil
    return [code, nil] if message.blank?
    message.sub! /\@\w*/ do |c|
      code = c[1..-1]; ''
    end
    [code, message.strip]
  end

  def calculate_hours
    return false if followup.nil?
    self.finished_at = followup.created_at
  end

  def process_previous
    previous.process! if previous
  end

  def cache_user_status
    User.update_all ['last_status_project_id = ?, last_status_id = ?, last_status_message = ?, last_status_at = ?', project_id, id, message, created_at], ['id = ?', user_id]
  end

  def times_are_sane
    if finished_at && created_at > finished_at
      errors.add_to_base "Can't finish before you start! (Extreme GTD)"
    end
  end
end
