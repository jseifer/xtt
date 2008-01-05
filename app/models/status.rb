class Status < ActiveRecord::Base
  validates_presence_of :user_id, :message
  
  attr_writer :followup
  
  belongs_to :user
  
  acts_as_state_machine :initial => :pending
  state :pending, :enter => :process_previous
  state :processed
  
  event :process do
    transitions :from => :pending, :to => :processed, :guard => :calculate_hours
  end

  def followup
    @followup ||= user.statuses.after(self) || :false
    @followup == :false ? nil : @followup
  end
  
  def previous
    @previous ||= user.statuses.before(self) || :false
    @previous == :false ? nil : @previous
  end

protected
  def calculate_hours
    return false if followup.nil?
    self.hours = ((followup.created_at - created_at).to_f / 1.hour.to_f).ceil
  end
  
  def process_previous
    previous.process! if previous && previous.pending?
  end
end