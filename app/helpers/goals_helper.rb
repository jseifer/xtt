module GoalsHelper
  
  def js_link_to_days(num, field, text=nil)
    if num.is_a?(Fixnum)
      "<a href=\"#\" onclick=\"$('#{field}').value = '#{(Time.now + num.days).strftime('%a %m/%d/%Y')}'\">#{text || pluralize(num, 'day')} (#{(Time.now + num.days).strftime('%a %b %d %Y') })</a>"
    else
      "<a href=\"#\" onclick=\"$('#{field}').value = '#{num.strftime('%a %m/%d/%Y')}'\">#{text || num.strftime('%a %b %d %Y') }</a>"
    end
  end
end
