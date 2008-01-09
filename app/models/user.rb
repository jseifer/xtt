class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods, ProjectParent
  
  before_create { |u| u.admin = true if User.count.zero? }
  
  has_many :groups, :through => :memberships
  has_many :recent_projects, :through => :statuses, :class_name => Project.name do
    def latest
      @latest ||= find(:first)
    end
  end
  
  has_finder :all, :order => 'login'
end
