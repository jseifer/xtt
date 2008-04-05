class Context < ActiveRecord::Base
  has_many :memberships
  belongs_to :user
  
  validates_uniqueness_of :name, :scope => :user_id
  
  def after_create
    unless user_id
      update_attribute :user_id, memberships[0].user_id unless memberships.empty?
    end
  end

end