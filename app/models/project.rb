class Project < ActiveRecord::Base
  include Status::Methods
  
  has_finder :all, :order => 'name'
end