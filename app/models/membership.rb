class Membership < ActiveRecord::Base
  class InvalidCodeError < StandardError; end

  belongs_to :project
  belongs_to :user
  belongs_to :context

  validates_presence_of :project_id, :user_id
  validates_uniqueness_of :code, :scope => :user_id
  validates_uniqueness_of :project_id, :scope => :user_id
  
  def code
    (self[:code].nil? || self[:code].empty?) && project ? project.code : self[:code]
  end
  
  def self.find_by_code(code)
    first(:conditions => {:code => code}) || raise(InvalidCodeError)
  end

  def find_for(user_id, project_ids)
    find(:all, :conditions => ['user_id=? AND project_id IN (?)', user_id, project_ids])
  end
  
  def context_name
    context ? context.name : ''
  end

  def context_name=(val)
    self.context = user.contexts.find_or_create_by_name(val)
  end
end
