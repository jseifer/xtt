class User::Mailer < ActionMailer::Base
  include ActionController::UrlWriter

  def activation(user)
    setup_user(user)
    @subject = "New tt account"
  end

  def forgot_password(user)
    setup_user(user)
    @subject = "[tt] Request to change your password."
  end
  
  def project_invitation(project, user)
    setup_user(user)
    @setup = "[tt] You've been invited to the #{project.name.inspect} project."
    @body[:project] = project
    @body[:url]     = project_url(:id => project, :host => TT_HOST)
  end

  protected
    def setup_user(user)
      @from        = "#{TT_EMAIL}"
      @sent_on     = Time.now
      @recipients  = "#{user.email}"
      @body[:user] = user
      @body[:url]  = activate_url(:activation_code => user.activation_code, :host => TT_HOST)
    end
end
