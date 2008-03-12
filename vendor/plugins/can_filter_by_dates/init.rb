# Include hook code here
class << ActiveRecord::Base
  def can_filter_by_dates(filters = {})
    extend CanFilterByDates
    date_filters.update(filters)
  end
end