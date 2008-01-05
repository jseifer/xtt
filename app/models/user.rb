class User < ActiveRecord::Base
  concerned_with :validation, :authentication, :state_machine
end
