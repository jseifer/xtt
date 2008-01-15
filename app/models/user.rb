class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods
  
  attr_readonly :last_status_project_id, :last_status_id, :last_status_message
  
  before_create { |u| u.admin = true if User.count.zero? }
  
  belongs_to :last_status_project, :class_name => "Project"
  belongs_to :last_status, :class_name => "Status"

  has_many :memberships, :dependent => :delete_all
  has_many :projects, :order => 'projects.name', :through => :memberships
  has_many :owned_projects, :order => 'projects.name', :class_name => 'Project'
  has_many :recent_projects, :through => :statuses, :class_name => Project.name, :source => :project do
    def latest
      @latest ||= find(:first)
    end
  end

  has_finder :all, :order => 'login'
end
