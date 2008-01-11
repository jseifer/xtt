class Status < ActiveRecord::Base
  validates_presence_of :user_id, :message
  
  attr_writer :followup
  
  belongs_to :user
  belongs_to :project
  
  has_finder :for_group, lambda { |group| { :conditions => ['projects.parent_id = ? and projects.parent_type = ?', group.id, Group.name], 
      :joins => "INNER JOIN projects ON statuses.project_id = projects.id", :extend => LatestExtension} } 

  has_finder :for_project, lambda { |project| { :conditions => {:project_id => project.id}, :extend => LatestExtension } }
  has_finder :without_project, :conditions => {:project_id => nil}, :extend => LatestExtension
  
  acts_as_state_machine :initial => :pending
  state :pending, :enter => :process_previous
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
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
  
  def billable?
    project && project.billable?
  end
  
  def project?
    !project_id.nil?
  end

  def accurate_time
    return if created_at.nil?
    (followup ? followup.created_at : Time.now) - created_at
  end
  
  def editable_by?(user)
    user && user_id == user.id
  end
  
  def followup_time=(new_time)
    followup.update_attribute :created_at, round_time(new_time)
  end

  def followup_time
    t = followup.created_at.to_f
    round_time(t)
  end

  def fixed_created_at
    round_time created_at
    #round_time(read_attribute(:created_at).utc)
  end
  def fixed_created_at=(new_time)
    write_attribute :created_at, round_time(Time.parse(new_time))
  end
  
  def round_time(t)
    t = t.to_f
    Time.at(t - (t%300)).utc
  end

protected
  def calculate_hours
    return false if followup.nil?
    quarters = billable? ? (accurate_time.to_f / 15.minutes.to_f).ceil : 0
    self.hours = quarters.to_f / 4.0
  end
  
  def process_previous
    previous.process! if previous && previous.pending?
  end
end
