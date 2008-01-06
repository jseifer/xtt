class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  include Status::Methods
  
  validates_presence_of :account_id
  
  belongs_to :account
  
  has_many :projects, :through => :statuses do
    def latest
      @latest ||= find(:first)
    end
  end
end
