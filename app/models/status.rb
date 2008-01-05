class Status < ActiveRecord::Base
  validates_presence_of :user_id, :message
  
  belongs_to :user
end