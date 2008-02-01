class User::Mailer < ActionMailer::Base
  include ActionController::UrlWriter

  def activation(user)
    return if ApplicationController.host_name.blank?
    setup_user(user)
    @subject = "New tt account"
  end

  def forgot_password(user)
    return if ApplicationController.host_name.blank?
    setup_user(user)
    @subject = "[tt] Request to change your password."
  end

  protected
    def setup_user(user)
      @from        = "#{TT_EMAIL}"
      @sent_on     = Time.now
      @recipients  = "#{user.email}"
      @body[:user] = user
      @body[:url]  = activate_url(:activation_code => user.activation_code, :host => ApplicationController.host_name)
    end
end
