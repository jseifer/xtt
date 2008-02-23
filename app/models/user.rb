class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  
  attr_readonly :last_status_project_id, :last_status_id, :last_status_message
  
  before_create { |u| u.admin = true if User.count.zero? }
  
  belongs_to :last_status_project, :class_name => "Project"
  belongs_to :last_status, :class_name => "Status"

  has_many :statuses, :order => 'statuses.created_at desc', :extend => Status::Methods::AssociationExtension do
    def filter(filter = :weekly, options = {})
      Status.filter proxy_owner.id, filter, options
    end

    def filtered_hours(filter = :weekly, options = {})
      Status.filtered_hours proxy_owner.id, filter, options
    end
    
    def hours(filter = :weekly, options = {})
      Status.hours proxy_owner.id, filter, options
    end
  end
  
  has_many :owned_projects, :order => 'projects.name', :class_name => 'Project'

  has_many :memberships, :dependent => :delete_all
  has_many :projects, :order => 'projects.name', :through => :memberships
  
  has_many :recent_projects, :through => :statuses, :class_name => Project.name, :source => :project do
    def latest
      @latest ||= find(:first)
    end
  end

  has_finder :all, :order => 'login'
  
  def post(message, forced_project = nil, source = 'the web')
    statuses.create :project => forced_project, :code_and_message => message, :source => source
  end
  
  def related_users
    @related_users ||= with_memberships { User.find :all, :order => 'last_status_at desc', :select => "DISTINCT users.*" }
  end
  
  def related_to?(user)
    @related_users ? @related_users.include?(user) : with_memberships { User.exists?(user.id) }
  end
  
  def can_access?(user_or_status_or_project)
    case user_or_status_or_project
      when Status  then can_access_status?(user_or_status_or_project)
      when User    then can_access_user?(user_or_status_or_project)
      when Project then accessible_project_id?(user_or_status_or_project.id)
      else false
    end
  end

protected
  def with_memberships
    project_ids = memberships.collect { |m| m.project_id }
    project_ids.uniq!
    self.class.send(:with_scope, :find => {:conditions => ['users.id != ? and memberships.project_id IN (?)', id, project_ids], :joins => "INNER JOIN memberships ON users.id = memberships.user_id"}) do
      yield
    end
  end
  
  def can_access_status?(status)
    status.project_id.nil? ||
      status.user_id == id ||
      accessible_project_id?(status.project_id)
  end
  
  def can_access_user?(user)
    user == self || user.last_status_project_id.nil? || accessible_project_id?(user.last_status_project_id)
  end
  
  def accessible_project_id?(project_id)
    projects.loaded? ? 
      projects.collect { |p| p.id }.include?(project_id) :
      projects.exists?(['projects.id = ?', project_id])
  end
end
