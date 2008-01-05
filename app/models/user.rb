class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  
  has_many :statuses, :order => 'created_at desc'
end
