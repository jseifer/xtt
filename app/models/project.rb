class Project < ActiveRecord::Base
  include Status::Methods
end