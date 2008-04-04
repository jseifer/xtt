class Project < ActiveRecord::Base
  class InvalidCodeError < StandardError; end
  include Status::Methods
  
  validates_presence_of :user_id, :name, :code
  
  belongs_to :user
  has_many :feeds
  has_many :memberships, :dependent => :delete_all
  has_many :users, :order => 'login', :through => :memberships do
    def include?(user)
      proxy_owner.user_id == user.id || (loaded? ? @target.include?(user) : exists?(user.id))
    end
  end
  
  before_validation :create_code
  validates_uniqueness_of :code
  after_save :create_membership
  
  has_finder :all, :order => 'name'
  
  def self.find_by_code(code)
    find(:first, :conditions => {:code => code}) || raise(InvalidCodeError)
  end
  
  def editable_by?(user)
    users.include?(user)
  end
  
  def owned_by?(user)
    user && user_id == user.id
  end

protected
  def create_membership
    memberships.create :user_id => user_id
  end
  
  def create_code
    if code.blank?
      self.code = name.to_s.dup
      code.gsub!(/\W/, '')
      code.downcase!
    end
  end
end