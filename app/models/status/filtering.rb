class Status
  can_search do
    scoped_by :user
    scoped_by :project
    scoped_by :created, :scope => :date_range
  end

  module FilteredHourMethods
    def self.extended(hours)
      hours.collect! do |(grouped, hour)|
        user_id, date = grouped.split("::")
        [user_id.to_i, Time.parse(date), hour]
      end
      hours.sort! { |x, y| x.last <=> y.last }
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
  
  class << self
    attr_accessor :filter_types
  end
  
  self.filter_types = Set.new CanSearchInScopes::DateRangeScope.periods.keys
  
  # user_id can be an integer or nil
  def self.filter(user_id, filter, options = {})
    range   = filter ? date_range_for(filter, options[:date]) : nil
    records = search :user => user_id, :created => range,
      :order => 'statuses.created_at desc', :page => options[:page], :per_page => options[:per_page]
    [records, range]
  end
  
  def self.hours(user_id, filter, options = {})
    search_for(:user => user_id, :created => {:period => filter, :start => options[:date]}).sum :hours
  end
  
  def self.filtered_hours(user_id, filter, options = {})
    hours = search_for(:user => user_id, :created => {:period => filter, :start => options[:date]}).sum :hours,
      :group => "CONCAT(user_id, '::', DATE(CONVERT_TZ(created_at, '+00:00', '#{Time.zone.utc_offset_string}')))"
    hours.extend(FilteredHourMethods)
  end
end