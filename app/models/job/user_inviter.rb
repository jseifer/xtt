class Job::UserInviter < Job::Base.new(:project, :user)

  def perform
    case user.class.name
    when 'User'
      User::Mailer.deliver_project_invitation project, user
    when 'Invitation'
      User::Mailer.deliver_new_invitation project, user
    else
      raise "Unsupported invitation type '#{user.class.name}'"
    end
  end

end