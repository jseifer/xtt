class User::Inviter
  attr_reader :logins, :emails, :project
  
  def self.invite(project_id, string)
    i = new(project_id, string)
    i.invite
    i
  end
  
  def initialize(project_id, string)
    @project = Project.find project_id
    @emails, @logins = parse(string)
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
    @new_emails ||= begin
      existing = Set.new users.collect { |u| u.email }
      @emails.reject { |e| existing.include? e }
    end
  end
  
protected
  def parse(string)
    entries = string.split(',').each { |s| s.strip! ; s.downcase! }
    entries.partition { |e| e =~ /\W/ }
  end
end