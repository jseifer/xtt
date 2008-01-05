class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
end
