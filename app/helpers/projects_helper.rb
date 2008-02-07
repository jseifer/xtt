module ProjectsHelper
  def link_to_project(project, text = nil, url_for_options = nil)
    link_to h(text || project.name), url_for_options || project
  end
  
  def paging_for_period(date_range)
    return if date_range.nil?
    filter = params[:filter]
    prev, nnext = date_range.first
    case filter
      when 'daily'
        prev_item = (prev - 1.day).strftime("%A") if prev
        next_item = (nnext + 1.day).strftime("%A") if nnext
      when 'weekly'
        prev_item = "Previous week" if prev
        next_item = "Following week" if nnext
    end
    %(<span class="paging">
        #{link_to_filtered_statuses('&larr; ' + prev_item) if prev_item}
        #{link_to_filtered_statuses(next_item + ' &rarr;') if next_item}
      </span>)
  end
end
