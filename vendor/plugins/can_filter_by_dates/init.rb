# Include hook code here
class << ActiveRecord::Base
  def can_filter_by_dates
    extend CanFilterByDates
  end
end