class Status
  has_finder :for_project, lambda { |project| { :conditions => {:project_id => project.id}, :extend => LatestExtension } }
  has_finder :without_project, :conditions => {:project_id => nil}, :extend => LatestExtension
  
  class << self
    attr_accessor :filter_types
  end
  
  self.filter_types = Set.new %w(daily weekly bi-weekly monthly)

  def self.with_user(user, &block)
    return block.call if user.nil?
    user_id = user.is_a?(User) ? user.id : user
    with_scope :find => { :conditions => ['statuses.user_id = ?', user_id] }, &block
  end
  
  def self.in_projects(user_or_projects, &block)
    projects = user_or_projects.is_a?(User) ? user_or_projects.projects : user_or_projects
    with_scope :find => { :conditions => ['statuses.project_id is null or statuses.project_id IN (?)', projects] }, &block
  end
  
  def self.with_date_filter(filter, now = nil, &block)
    now = case now
      when String then Time.parse(now).change_time_zone_to_current
      when nil    then Time.zone.now
      when Time, DateTime, Date, ActiveSupport::TimeWithZone then now
      else raise "Invalid date filteR: #{now.inspect}"
    end
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
  def self.filter(user_id, filter, options = {})
    with_user user_id do
      with_date_filter(filter, options[:date]) { paginate :order => 'statuses.created_at desc', :page => options[:page] }
    end
  end
  
  def self.filtered_hours(user_id, filter, options = {})
    with_user user_id do
      with_date_filter(filter, options[:date]) { calculate :sum, :hours }.first
    end
  end
   
  def self.since(date, &block)
    with_scope :find => { :conditions => ['hours is not null and created_at >= ?', date.utc.midnight] }, &block
  end
end