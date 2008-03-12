module ProjectsHelper
  def link_to_project(project, text = nil, url_for_options = nil)
    link_to h(text || project.name), url_for_options || project
  end
  
  def period_to_sentence(filter, date_range, hours)
    plural = hours == 1 ? 'hour' : 'hours'
    filter = filter.to_sym if filter
    final = case filter
      when :daily
        date_range.first.strftime("%A, %b %d")
      when :monthly
        "for #{date_range.first.strftime("%B")}"
      when :'bi-weekly', :weekly
        "#{date_range.first.strftime("%B %d")}-#{date_range.last.strftime("%d")}"
    end
    %(#{plural} <span class="daterange">#{final}</span>)
  end
  
  def normalized_max(data)
    ((data.collect{|d| d.to_f}.max * 10**-1).ceil.to_f / 10**-1).to_i
  end
  
  def csv(str)
    '"' + h(str).gsub('"', '""') + '"'
  end
end
