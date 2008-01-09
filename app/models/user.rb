class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods, Project::Parent
  
  before_create { |u| u.admin = true if User.count.zero? }
  
  has_many :groups, :through => :memberships
  has_many :owned_groups, :class_name => 'Group', :foreign_key => :owner_id
  has_many :recent_projects, :through => :statuses, :class_name => Project.name, :source => :project do
    def latest
      @latest ||= find(:first)
    end
  end
  
  has_finder :all, :order => 'login'
end
