class Context < ActiveRecord::Base
  has_many :memberships
  belongs_to :user

  has_permalink :name

  validates_uniqueness_of :name, :scope => :user_id

  def to_param
    permalink
  end
end