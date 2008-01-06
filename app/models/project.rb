class Project < ActiveRecord::Base
  include Status::Methods
  
  validates_presence_of :account_id, :name

  belongs_to :account
  
  has_finder :all, :order => 'name'
end