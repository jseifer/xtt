class Project < ActiveRecord::Base
  include Status::Methods
  
  validates_presence_of :parent_id, :parent_type, :name

  belongs_to :parent, :polymorphic => true
  
  has_finder :all, :order => 'name'

end