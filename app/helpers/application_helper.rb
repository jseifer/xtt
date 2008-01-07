# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def nice_time(seconds)
    seconds = seconds.to_i
    return '0' unless seconds > 0
    hours   = seconds / 1.hour
    seconds = seconds % 1.hour
    minutes = seconds / 1.minute
    seconds = seconds % 1.minute
    (hours > 0 ? "#{hours}:" : '') + ('%02d:%02d' % [minutes, seconds])
  end

end
