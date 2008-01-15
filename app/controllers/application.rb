# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time
  before_filter :adjust_format_for_iphone

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b26d74a5338fb7435501904f0451dc26'

  helper_method :iphone_user_agent?

protected
  def iphone_user_agent?
    @iphone_user_agent ||= (request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/(Mobile\/.+Safari)/]) || :false
    @iphone_user_agent  != :false
  end

  # Set iPhone format if request to iphone.trawlr.com
  def adjust_format_for_iphone    
    request.format = :iphone if iphone_user_agent?
  end
end
