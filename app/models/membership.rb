class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user
  
  validates_presence_of :group_id, :user_id
  validate :unique?
  
protected
  def unique?
    errors.add_to_base "Duplicate Membership for User and Group" if self.class.exists?(attributes)
  end
end
