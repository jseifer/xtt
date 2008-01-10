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

  def nice_timer_for(status)
    if status.followup.nil?
      (@content_for_head ||= "")
      @content_for_head += <<-JS
  <script type='text/javascript'>
    new PeriodicalExecuter(function() { timerIncrement('timer_#{dom_id(status)}') }, 1);
  </script>
JS
    end
    "<span style=\"display:none\" id=\"timer_#{dom_id status}\">#{status.created_at.to_f}</span><span class=\"timer\">#{nice_time(status.accurate_time)}</span>"
  end
  

end
