module CanSearchInScopes
  class DateRangeScope < BaseScope
    def self.periods() @periods ||= {} end
    periods.update \
      :daily => lambda { |now|
          today = now.midnight
          (today..today + 1.day - 1.second)
      },
      :weekly => lambda { |now|
        mon = now.beginning_of_week
        (mon..mon + 1.week - 1.second)
      },
      :'bi-weekly' => lambda { |now|
        today = now.midnight
        today.day >= 15 ? (today.change(:day => 15)..today.end_of_month) : (today.beginning_of_month..today.change(:day => 15) - 1.second)
      },
      :monthly => lambda { |now|
        (now.beginning_of_month..now.end_of_month)
      }
    
    def initialize(model, name, options = {})
      super
      @attribute = options[:attribute] || begin
        name_str = name.to_s
        name_str =~ /_at$/ ? name : (name_str << "_at").to_sym
      end
      @finder_name = options[:finder_name] || @name
      @model.named_scope @finder_name, lambda { |range|
        if range.respond_to?(:[])
          range = range[:period] && @model.date_range_for(range[:period], range[:start])
        end
        if range
          {:conditions => "#{@model.table_name}.#{@attribute} #{range.to_s :db}"}
        else
          {}
        end
      }
    end

    def scope_for(finder, options = {})
      if value = options.delete(@name)
        finder.send(@finder_name, value)
      else
        finder
      end
    end
  end

  # Custom ActiveRecord class methods
  def date_periods() @date_periods ||= CanSearchInScopes::DateRangeScope.periods.dup end

  def date_range_for(period_name, time = nil)
    if period = date_periods[period_name]
      period.call(parse_filtered_time(time))
    else
      raise "Invalid period: #{period_name.inspect}"
    end
  end

protected
  def parse_filtered_time(time = nil)
    case time
      when String then Time.zone.parse(time)
      when nil    then Time.zone.now
      when Time, ActiveSupport::TimeWithZone then time.in_time_zone
      else raise "Invalid time: #{time.inspect}"
    end
  end

  # Add this scope type
  SearchScopes.scope_types[:date_range] = DateRangeScope
end