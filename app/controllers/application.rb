# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'b26d74a5338fb7435501904f0451dc26'

  rescue_from Group::UndefinedError do |e|
    redirect_to new_group_path
  end

protected
  helper_method :group

  def group
    @group ||= Group.find_by_name(request.subdomains.first) or raise Group::UndefinedError
  end
end
