class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods
  
  has_many :memberships, :dependent => :delete_all
  has_many :groups, :through => :memberships
  
  has_many :projects, :through => :statuses do
    def latest
      @latest ||= find(:first)
    end
  end
  
  has_finder :all, :order => 'login'
end
