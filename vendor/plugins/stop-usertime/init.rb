require 'stop-user_time'

ActionView::Base.class_eval do
  include Stop::UserTime::ViewHelpers
end
