class Context < ActiveRecord::Base
  has_many :memberships
  belongs_to :user

  validates_uniqueness_of :name, :scope => :user_id

protected
  def after_create
    unless user_id || memberships.empty?
      update_attribute :user_id, memberships[0].user_id
    end
  end
end