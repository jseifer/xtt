class Status < ActiveRecord::Base
  validates_presence_of :user_id, :message
  
  attr_writer :followup
  
  belongs_to :user
  belongs_to :project

  has_finder :for_project, lambda { |project| { :conditions => {:project_id => project.id}, :extend => LatestExtension } }
  has_finder :without_project, :conditions => {:project_id => nil}, :extend => LatestExtension
  
  after_create :cache_user_status
  
  acts_as_state_machine :initial => :pending
  state :pending, :enter => :process_previous
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
  end
  
  def self.with_user(user, &block)
    with_scope :find => { :conditions => ['statuses.user_id = ?', user.id] }, &block
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
  
  def project?
    !project_id.nil?
  end

  # The accurate amount of time (not rounded) this project has taken.
  def accurate_time
    return if created_at.nil?
    (followup ? followup.created_at : Time.now) - created_at
  end
  
  def editable_by?(user)
    user && user_id == user.id
  end
  
  def validate #_followup_does_not_clash
    return true if (user.nil? or followup.nil? or followup.followup.nil?)
    value = followup.followup_time
    if followup_time > value
      errors.add :followup_time, "Cannot extend this status to after the next status' end-point. Delete the next status." 
      return false
    else
      # errors.add :followup_time, "Cannot extend this status to after the next status' end-point. Delete the next status." 
      # n othing
    end
  end
  
  # Set the end time (aka followup time) of this item
  # Don't allow setting a followup time past the next status's finish time.
  def followup_time=(new_time)
    time = Time.parse(new_time.to_s)
    raise "No followup" unless followup
    if followup.followup.nil? or # followup is still in play, so we don't care about adjusting its start time or 
      (followup.followup_time) # we have something to check against

      if followup_time > time
        errors.add :followup_time, "Cannot extend this status to after the next status' end-point. Delete the next status." 
        return false
      else
        followup.update_attribute :created_at, time # round_time(new_time)
      #else
      #  raise "not valid"
      end
    end
  end
  def followup_time
    followup.created_at
    #t = followup.created_at.to_f
    #round_time(t)
  end
  
  # Set the created_at time, but rounded to the nearest 5 minutes.
  def fixed_created_at
    round_time created_at
  end
  def fixed_created_at=(new_time)
    write_attribute :created_at, round_time(Time.parse(new_time))
  end
  
  # Round times down to the nearest 5 minutes
  def round_time(t)
    t = t.to_f
    Time.at(t - (t%300)).utc
  end

protected
  def calculate_hours
    return false if followup.nil?
    quarters = (accurate_time.to_f / 15.minutes.to_f).ceil
    self.hours = quarters.to_f / 4.0
  end
  
  def process_previous
    previous.process! if previous && previous.pending?
  end
  
  def cache_user_status
    User.update_all ['last_status_project_id = ?, last_status_id = ?, last_status_message = ?, last_status_at = ?', project_id, id, message, created_at], ['id = ?', user_id]
  end
end
