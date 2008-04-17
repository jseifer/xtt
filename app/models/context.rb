class Context < ActiveRecord::Base
  has_many :memberships
  has_many :projects, :through => :memberships
  has_many :users,    :through => :memberships, :uniq => true
  belongs_to :user

  has_permalink :name

  validates_uniqueness_of :name, :scope => :user_id

  def to_param
    permalink
  end
end