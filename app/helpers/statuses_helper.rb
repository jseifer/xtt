module StatusesHelper
  def status_summary(project)
    project.nil? ? "is out" : "is working on #{h(project.name)}"
  end
  
  def status_for(user_or_status)
    message = user_or_status.is_a?(User) ? user_or_status.last_status_message : user_or_status.message
    message.blank? ? "No update" : h(message)
  end
  
  def status_at(status_or_date)
    created_at = case status_or_date
      when User   then status_or_date.last_status_at
      when Status then status_or_date.created_at
      else status_or_date
    end
    created_at && "#{js_time_ago_in_words created_at} ago"
  end
end
