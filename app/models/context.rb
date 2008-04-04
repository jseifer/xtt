class Context < ActiveRecord::Base
  has_many :memberships
  belongs_to :user
  
  def after_save
    unless user_id
      update_attribute :user_id, memberships[0].user_id unless memberships.empty?
    end
  end

end
