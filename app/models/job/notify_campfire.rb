class Job::NofifyCampfire < Job::Base.new(:campfire, :message)

  # tinder_room.speak message
  def perform
    campfire.tinder_room.speak message
  end
end