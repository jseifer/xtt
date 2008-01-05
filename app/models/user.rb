class User < ActiveRecord::Base
  concerned_with :authentication, :state_machine
  
  has_many :statuses, :order => 'statuses.created_at desc' do
    def after(status)
      find(:first, :conditions => ['statuses.created_at > ?', status.created_at], :order => 'statuses.created_at')
    end
    
    def before(status)
      find(:first, :conditions => ['statuses.created_at < ?', status.created_at], :order => 'statuses.created_at desc')
    end
  end
end
