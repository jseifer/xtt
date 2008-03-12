module CanSearchInScopes
  class DateRangeScope < BaseScope
    def self.periods() @periods ||= {} end
    periods.update \
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

    def initialize(name, options = {})
      super
      @attribute ||= begin
        name_str = name.to_s
        name_str =~ /_at$/ ? name : (name_str << "_at").to_sym
      end
    end
    
    def self.scope_options_for(search_scopes, options = {})
      search_scopes.scopes_by_type[self].inject([]) do |all, scope|
        value = options.delete(scope.name)
        if value.respond_to?(:[])
          unless period = search_scopes.model.date_periods[value[:period]]
            raise "Unknown period: #{value[:period].inspect}"
          end
          date  = parse_filtered_time(value[:start])
          value = period.call(date)
        end
        if value
          all << {:conditions => "#{search_scopes.model.table_name}.#{scope.attribute} #{value.to_s :db}"}
        else
          all
        end
      end
    end

    def self.parse_filtered_time(date = nil)
      case date
        when String then Time.parse(date).change_time_zone(Time.zone)
        when nil    then Time.zone.now
        when Time, ActiveSupport::TimeWithZone then date.in_current_time_zone
        else raise "Invalid date: #{date.inspect}"
      end
    end
  end

  # Custom ActiveRecord class methods
  def date_periods() @date_periods ||= CanSearchInScopes::DateRangeScope.periods.dup end

  def with_date_period(attribute, period_name, date = nil, &block)
    if period_name
      unless period = date_periods[period_name.to_sym]
        raise "Unknown period: #{period_name.inspect}"
      end
      date  = CanSearchInScopes::DateRangeScope.parse_filtered_time(date)
      range = period.call(date)
      [with_date_range(attribute, range, &block), range]
    else
      [block.call, nil]
    end
  end

  def with_date_range(attribute, range, &block)
    with_scope :find => { :conditions => "#{table_name}.#{attribute} #{range.to_s :db}" }, &block
  end

  # Add this scope type\
  SearchScopes.scope_types[:date_range] = DateRangeScope
end