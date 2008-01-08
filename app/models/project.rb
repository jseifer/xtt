class Project < ActiveRecord::Base
  include Status::Methods
  
  validates_presence_of :group_id, :name

  belongs_to :group
  
  has_finder :all, :order => 'name'

end