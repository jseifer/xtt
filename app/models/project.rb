class Project < ActiveRecord::Base
  include Status::Methods
  
  validates_presence_of :parent_id, :parent_type, :name

  belongs_to :parent, :polymorphic => true
  
  has_finder :all, :order => 'name'

  def editable_by?(user)
    user && 
      (parent_type == User.name && parent_id == user.id) ||
      (parent_type == Group.name && parent.users.include?(user))
  end
end