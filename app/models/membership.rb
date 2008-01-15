class Membership < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project_id, :user_id
  validate :unique?
  
protected
  def unique?
    errors.add_to_base "Duplicate Membership for User and Project" if self.class.exists?(attributes)
  end
end
