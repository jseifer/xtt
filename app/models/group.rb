class Group < ActiveRecord::Base
  include Project::Parent

  validates_presence_of :name, :owner_id
  validates_uniqueness_of :name
  
  belongs_to :owner, :class_name => User.name
  has_many :users, :order => 'login', :through => :memberships do
    def include?(user)
      proxy_owner.owner_id == user.id || (loaded? ? @target.include?(user) : exists?(user.id))
    end
  end
end