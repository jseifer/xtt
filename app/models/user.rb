class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods
end
