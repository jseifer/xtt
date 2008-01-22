class Status
  
  # The accurate amount of time (not rounded) this project has taken.
  def accurate_time
    return if created_at.nil?
    (followup ? followup.created_at : Time.now) - created_at
  end
  
  # Set the end time (aka followup time) of this item
  # Don't allow setting a followup time past the next status's finish time.
  def followup_time=(new_time)
    new_time = new_time.to_s.gsub(/GMT([-+]\d)/, "\\1")
    time = Time.parse(new_time.to_s).utc
    
    # Ensure there is a next object to set the create time
    raise "No followup for #{id}" unless followup
    # Todo: just auto-create a new status?
    
    # Now, check that we can set the next object's created_at time correctly.
    if followup.followup.nil? or # followup is still in play, so we don't care about adjusting its start time or 
      (followup.followup_time) # confirm we actually have something to check against

      if followup_time > time
        raise "invalid"
        errors.add :followup_time, "Cannot extend this status to after the next status' end-point. Delete the next status." 
        return false
      else
        followup.update_attribute :created_at, time # round_time(new_time)
      #else
      #  raise "not valid"
      end
    end
  end
  def followup_time
    followup.created_at
    #t = followup.created_at.to_f
    #round_time(t)
  end
  
  # Javascript times get formatted weirdly so we have to parse them and otherwise munge
  def set_created_at=(new_time)
    new_time = new_time.to_s.gsub(/GMT([-+]\d)/, "\\1")
    time = Time.parse(new_time.to_s).utc
    if previous and previous.created_at.to_i >= time.to_i
      errors.add :created_at, "Cannot set the start time before the previous status' start time."
      return false
    else
      write_attribute :created_at, time      
    end
  end
  
  # Set the created_at time, but rounded to the nearest 5 minutes.
  def fixed_created_at
    round_time created_at
  end
  def fixed_created_at=(new_time)
    write_attribute :created_at, round_time(Time.parse(new_time))
  end
  
  # Round times down to the nearest 5 minutes
  def round_time(t)
    t = t.to_f
    Time.at(t - (t%300)).utc
  end
  
end