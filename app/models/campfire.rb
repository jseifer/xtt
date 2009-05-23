class Campfire < ActiveRecord::Base
  has_many :tendrils, :as => :notifies
  has_many :projects, :through => :tendrils
  belongs_to :user # creator

  def send_message(message)
    Job::NotifyCampfire.create self, message
  end
  
  def tinder_room
    @tinder_room ||= self.name ? tinder.rooms.select { |r| r.name == room }[0] : tinder.rooms[0]
  end

private

  def tinder
    return @tinder if @tinder
    @tinder = Tinder::Campfire.new domain, :ssl => false # should be customizable
    @tinder.login login, password
    @tinder
  end

end
