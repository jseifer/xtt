module StatusesHelper
  def status_summary(project)
    return 'is out' if project.nil?
    current_user.can_access?(project) ? "is working on #{h(project.name)}" : "is busy"
  end
  
  def status_for(user_or_status)
    message = user_or_status.is_a?(User) ? user_or_status.last_status_message : user_or_status.message
    if message.blank?
      'No update'
    elsif current_user.can_access?(user_or_status)
      h(message)
    else
      'Busy'
    end
  end
  
  def status_at(status_or_date)
    created_at = case status_or_date
      when User   then status_or_date.last_status_at
      when Status then status_or_date.created_at
      else status_or_date
    end
    created_at && "#{js_time_ago_in_words created_at}"
  end
end
