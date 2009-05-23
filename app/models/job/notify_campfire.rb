class Job::NotifyCampfire < Job::Base.new(:campfire, :message)

  # tinder_room.speak message
  def perform
    return if Rails.env == 'test'
    campfire.tinder_room.speak message
  end
end