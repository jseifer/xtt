class User::Inviter
  attr_reader :logins, :emails, :project
  
  def self.invite(project_id, string)
    i = new(project_id, string)
    i.invite
    i
  end
  
  def initialize(project_id, string)
    @project = Project.find(project_id)
    @emails, @logins = [], []
    parse(string)
  end
  
  def invite
    users.each do |user|
      @project.users << user
      User::Mailer.deliver_project_invitation @project, user
    end
  end
  
  def users
    if @users.nil?
      @users = @logins.empty? ? [] : User.find(:all, :conditions => {:login => @logins})
      @users.push(*User.find(:all, :conditions => ['email IN (?) and id NOT IN (?)', @emails, @users.collect { |u| u.id }]))
    end
    @users
  end
  
  def new_emails
    @new_emails ||= @emails - existing_emails
  end
  
  def existing_emails
    @existing_emails ||= users.collect { |u| u.email }
  end
  
  def to_job
    %{script/runner "User::Inviter.invite(#{@project.id}, '#{(logins + emails) * ", "}')"}
  end
  
protected
  def parse(string)
    string.split(',').each do |s| 
      s.strip! ; s.downcase!
      @emails << s if s =~ User.email_format
      @logins << s if s =~ User.login_format
    end
  end
end