require 'time'
module CanFilterByDates
  def self.filters() @filters ||= {} end
  filters[nil] = lambda { |now, block|}

  def date_filters() @date_filters ||= CanFilterByDates.filters.dup end

  def with_date_filter(attribute, filter, now = nil, &block)
    if filter
      unless filter = date_filters[filter.to_sym]
        raise "Unknown filter: #{filter.inspect}"
      end
      now   = parse_filtered_time(now)
      range = filter.call(now)
      [with_date_range(attribute, range, &block), range]
    else
      [block.call, nil]
    end
  end
  
  def parse_filtered_time(now = nil)
    case now
      when String then can_filter_by_dates_parse_time(now)
      when nil    then can_filter_by_dates_current_time
      when Time, ActiveSupport::TimeWithZone then now.in_current_time_zone
      else raise "Invalid date: #{now.inspect}"
    end
  end

  def with_date_range(attribute, range, &block)
    with_scope :find => { :conditions => "#{table_name}.#{attribute} #{range.to_s :db}" }, &block
  end

private
  # yay for possible namespace clashing
  def can_filter_by_dates_current_time
    Time.zone.now
  end
  
  def can_filter_by_dates_parse_time(string)
    Time.parse(string).change_time_zone(Time.zone)
  end
end

if defined?(ActiveSupport)
  CanFilterByDates.filters.update \
    :daily => lambda { |now|
        today = now.midnight
        (today..today + 1.day)
    },
    :weekly => lambda { |now|
      mon = now.beginning_of_week
      (mon..mon + 1.week)
    },
    :'bi-weekly' => lambda { |now|
      today = now.midnight
      today.day >= 15 ? (today.change(:day => 15)..today.end_of_month) : (today.beginning_of_month..today.change(:day => 15))
    },
    :monthly => lambda { |now|
      (now.beginning_of_month..now.end_of_month)
    }
end

unless defined?(ActiveSupport::TimeWithZone)
  Object.const_set(:ActiveSupport, Class.new) unless defined?(ActiveSupport)
  ActiveSupport.const_set(:TimeWithZone, Class.new)
  Time.class_eval do
    def in_current_time_zone() utc end
  end
  CanFilterByDates.module_eval do
    def can_filter_by_dates_current_time
      Time.now
    end
    
    def can_filter_by_dates_parse_time(string)
      Time.parse(string).utc
    end
  end
end