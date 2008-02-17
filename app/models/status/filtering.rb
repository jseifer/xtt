class Status
  module FilteredHourMethods
    def self.extended(hours)
      hours.collect! do |(grouped, hour)|
        user_id, date = grouped.split("::")
        [user_id.to_i, Time.parse(date), hour]
      end
    end

    def total(user_id = 0)
      user_id = case user_id
        when User then user_id.id
        when ActiveRecord::Base then user_id.user_id
        else user_id
      end.to_i
      @total ||= inject({}) do |total, (user, date, hour)|
        user        = user.to_i
        total[user] = hour.to_f + total[user].to_f
        total[0]    = hour.to_f + total[0].to_f unless user.zero?
        total
      end
      @total[user_id].to_f
    end
  end

  has_finder :for_project, lambda { |project| { :conditions => {:project_id => project.id}, :extend => LatestExtension } }
  has_finder :without_project, :conditions => {:project_id => nil}, :extend => LatestExtension
  
  class << self
    attr_accessor :filter_types
  end
  
  self.filter_types = Set.new [:daily, :weekly, :'bi-weekly', :monthly]

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
      when String then Time.parse(now).change_time_zone(Time.zone)
      when nil    then Time.zone.now
      when Time, DateTime, Date, ActiveSupport::TimeWithZone then now.in_current_time_zone
      else raise "Invalid date filter: #{now.inspect}"
    end
    filter = filter.to_sym if filter
    range = case filter
      when :daily
        today = now.midnight
        (today..today + 1.day)
      when :weekly
        mon = now.beginning_of_week
        (mon..mon + 1.week)
      when :'bi-weekly'
        today = now.midnight
        today.day >= 15 ? (today.change(:day => 15)..today.end_of_month) : (today.beginning_of_month..today.change(:day => 15))
      when :monthly
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
  
  def self.hours(user_id, filter, options = {})
    with_user user_id do
      with_date_filter(filter, options[:date]) { calculate :sum, :hours }.first
    end
  end
  
  def self.filtered_hours(user_id, filter, options = {})
    with_user user_id do
      hours = with_date_filter(filter, options[:date]) do
        calculate :sum, :hours, :group => "CONCAT(user_id, '::', DATE(CONVERT_TZ(created_at, '+00:00', '#{Time.zone.utc_offset_string}')))"
      end.first.extend(FilteredHourMethods)
    end
  end
end