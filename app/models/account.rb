class Account < ActiveRecord::Base
  class UndefinedError < StandardError; end

  validates_presence_of :host
  validates_uniqueness_of :host
  has_many :users, :order => 'login', :dependent => :destroy do
    def include?(user)
      loaded? ? @target.include?(user) : exists?(user.id)
    end
  end
  
  has_many :projects, :order => 'name',  :dependent => :destroy
  
  def host=(value)
    write_attribute :host, value.to_s.downcase
  end
end