class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods
  
  attr_readonly :last_status_project_id, :last_status_id, :last_status_message
  
  before_create { |u| u.admin = true if User.count.zero? }
  
  belongs_to :last_status_project, :class_name => "Project"
  belongs_to :last_status, :class_name => "Status"
  has_many :owned_projects, :order => 'projects.name', :class_name => 'Project'

  has_many :memberships, :dependent => :delete_all
  has_many :projects, :order => 'projects.name', :through => :memberships
  
  has_many :recent_projects, :through => :statuses, :class_name => Project.name, :source => :project do
    def latest
      @latest ||= find(:first)
    end
  end

  has_finder :all, :order => 'login'
  
  def post(message, forced_project = nil)
    code, message = extract_code_and_message(message)
    project       = forced_project || (code.nil? ? last_status_project : projects.find_by_code(code))
    statuses.create :project => project, :message => message
  end
  
  def related_users
    @related_users ||= User.find :all, :conditions => ['users.id != ? and memberships.project_id IN (?)', id, memberships.collect(&:project_id).uniq],
      :order => 'last_status_at desc', :joins => "INNER JOIN memberships ON users.id = memberships.user_id", :select => "DISTINCT users.*"
  end
  
  def total_hours(reload = false)
    @total_hours = nil if reload
    @total_hours ||= calculate_total_project_hours(projects)
  end
  
  def user_hours(reload = false)
    @user_hours = nil if reload
    @user_hours ||= Status.with_user(self) { calculate_total_project_hours(projects) }
  end

protected
  def calculate_total_project_hours(projects)
    Status.calculate :sum, :hours, :group => :project_id, 
      :conditions => ['hours is not null and project_id IN (?) and created_at >= ?', projects.collect { |p| p.id }, Time.now.utc.midnight]
  end

  def extract_code_and_message(message)
    code = nil
    message.sub! /\@\w*/ do |c|
      code = c[1..-1]; ''
    end
    [code, message.strip]
  end
end
