class User < ActiveRecord::Base
  concerns :authentication, :state_machine, :statuses
  
  before_create { |u| u.admin = true if User.count.zero? }

  has_many :campfires
  has_many :tendrils
    
  has_many :owned_projects, :order => 'projects.name', :class_name => 'Project'
  has_many :contexts, :order => 'contexts.name'
  has_many :memberships, :dependent => :delete_all do
    def for(project)
      loaded? ? 
        proxy_target.detect { |r| r.project_id == project.id } : 
        find(:first, :conditions => { :project_id => project.id})
    end
  end

  has_many :projects, :select => 'projects.*, memberships.code as project_code', :through => :memberships, :order => 'projects.name'
  
  has_many :recent_projects, :through => :statuses, :class_name => Project.name, :source => :project do
    def latest
      @latest ||= first
    end
  end

  named_scope :all, :order => 'login'
  
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

  def can_access_user?(user)
    user == self || user.last_status_project_id.nil? || accessible_project_id?(user.last_status_project_id)
  end
  
  def accessible_project_id?(project_id)
    projects.loaded? ? 
      projects.collect { |p| p.id }.include?(project_id) :
      projects.exists?(['projects.id = ?', project_id])
  end
end
