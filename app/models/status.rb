class Status < ActiveRecord::Base
  validates_presence_of :user_id, :message
  validate :followup_is_valid
  validate :previous_is_valid
  validate :times_are_sane
  
  concerned_with :hacky_date_methods
  
  attr_writer :followup
  attr_reader :active
  
  belongs_to :user
  belongs_to :project

  has_finder :for_project, lambda { |project| { :conditions => {:project_id => project.id}, :extend => LatestExtension } }
  has_finder :without_project, :conditions => {:project_id => nil}, :extend => LatestExtension
  
  after_create :cache_user_status
  after_create :process_previous
  
  acts_as_state_machine :initial => :pending
  state :pending
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
  end
  
  def self.with_user(user, &block)
    return block.call if user.nil?
    user_id = user.is_a?(User) ? user.id : user
    with_scope :find => { :conditions => ['statuses.user_id = ?', user_id] }, &block
  end
  
  def self.with_date_filter(filter, now = nil, &block)
    now ||= Time.zone.now
    range = case filter
      when 'daily'
        today = now.midnight
        (today..today + 1.day)
      when 'weekly'
        mon = now.beginning_of_week
        (mon..mon + 1.week)
      when 'bi-weekly'
        today = now.midnight
        today.day >= 15 ? (today.change(:day => 15)..today.end_of_month) : (today.beginning_of_month..today.change(:day => 15))
      when 'monthly'
        (now.beginning_of_month..now.end_of_month)
      when nil then return [block.call, nil]
      else raise "Unknown filter: #{filter.inspect}"
    end
    [with_date_range(range, &block), range]
  end
  
  def self.with_date_range(range, &block)
    with_scope :find => { :conditions => "statuses.created_at #{range.to_s :db}" }, &block
  end
  
  # user_id can be an integer or nil
  def self.filter(user_id, filter)
    with_user user_id do
      with_date_filter(filter) { find :all, :order => 'statuses.created_at desc' }
    end
  end
   
  def self.since(date, &block)
    with_scope :find => { :conditions => ['hours is not null and created_at >= ?', date.utc.midnight] }, &block
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
    user && user_id == user.id
  end

protected
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

  def followup_is_valid
    return if (user.nil? || followup.nil? || followup.followup.nil?)
    # no longer check for validity. :()
    #value = followup.followup_time
    #if followup_time > value
    #  errors.add :followup_time, "Cannot extend this status to after the next status' end-point. Delete the next status." 
    #end
  end
  
  def previous_is_valid
    #return if (user.nil? || previous.nil?)
    #if previous.created_at > created_at
    #  errors.add :created_at, "Cannot travel back in time with this status in hand."
    #end
  end
  
  def times_are_sane
    if !active? and created_at > finished_at
      errors.add_to_base "Can't finish before you start! (Extreme GTD)"
    end
  end
end
