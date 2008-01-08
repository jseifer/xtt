class Group < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  # has_many :memberships
  has_many :users, :order => 'login', :dependent => :destroy do
    def include?(user)
      loaded? ? @target.include?(user) : exists?(user.id)
    end
  end
  
  has_many :projects, :order => 'name',  :dependent => :destroy, :as => :parent
end