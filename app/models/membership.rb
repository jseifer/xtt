class Membership < ActiveRecord::Base
  class InvalidCodeError < StandardError; end

  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project_id, :user_id
  validates_uniqueness_of :code, :scope => :user_id
  validate :unique?
  
  def self.find_by_code(code)
    find(:first, :conditions => {:code => code}) || raise(InvalidCodeError)
  end

  def find_for(user_id, project_ids)
    find(:all, :conditions => ['user_id=? AND project_id IN (?)', user_id, project_ids])
  end

protected
  def unique?
    errors.add_to_base "Duplicate Membership for User and Project" if self.class.exists?(attributes)
  end
end
