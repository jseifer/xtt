class Project < ActiveRecord::Base
  include Status::Methods
  
  validates_presence_of :user_id, :name
  
  belongs_to :user
  has_many :memberships, :dependent => :delete_all
  has_many :users, :order => 'login', :through => :memberships do
    def include?(user)
      proxy_owner.user_id == user.id || (loaded? ? @target.include?(user) : exists?(user.id))
    end
  end
  
  after_save :create_membership
  
  has_finder :all, :order => 'name'
  
  def editable_by?(user)
    users.include?(user)
  end
  
  def name_with_parent
    (parent.is_a?(User) ? '' : "#{parent.name}: ") + name
  end

protected
  def create_membership
    memberships.create :user_id => user_id
  end
end