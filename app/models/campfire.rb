class Campfire < ActiveRecord::Base
  has_many :tendrils, :as => :notifies
  has_many :projects, :through => :tendrils
  belongs_to :user # creator

  def send_message(message)
    tinder_room.speak message
  end

private

  def tinder
    return @tinder if @tinder
    @tinder = Tinder::Campfire.new domain, :ssl => false
    @tinder.login login, password
    @tinder
  end

  def tinder_room
    @tinder_room ||= tinder.rooms.select { |r| r.name == room }[0]
  end

end
