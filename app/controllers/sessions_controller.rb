# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # render new.rhtml
  layout 'session'
  def new
  end

  def create
    if using_open_id?
      openid_auth(params[:openid_url])
    else
      password_auth(params[:login], params[:password])
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default
  end


protected

  def openid_auth(identity_url)
    authenticate_with_open_id(identity_url) do |status, identity_url|
      case status
      when :missing
        failed_login "Sorry, the OpenID server couldn't be found"
      when :canceled
        failed_login "OpenID verification was canceled"
      when :failed
        failed_login "Sorry, the OpenID verification failed"
      when :successful
        if self.current_user = @account.users.find_by_identity_url(identity_url)
          successful_login "Welcome!"
        else
          failed_login "Sorry, no user by that identity URL exists"
        end
      end
    end
  end
  
  def password_auth(login, password)
    self.current_user = User.authenticate(login, password)
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires_at }
      end
      successful_login "Logged in successfully"
    else
      failed_login "Invalid login or password."
    end
  end
  
  def failed_login(message)
    flash[:notice] = message
    render :action => "new"
  end
  
  def successful_login(message=nil)
    flash[:notice] = message
    redirect_back_or_default
  end

end

