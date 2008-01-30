module ProjectsHelper
  def link_to_project(project, text = nil, url_for_options = nil)
    link_to h(text || project.name), url_for_options || project
  end
  
  def link_to_filtered_statuses(text, options = {})
    user_id = options.key?(:user_id) ? options[:user_id] : params[:user_id]
    filter  = options.key?(:filter)  ? options[:filter]  : params[:filter]
    args    = {:id => params[:id]}
    prefix, args  = filter.blank? ? [nil, args] : ["filtered_", args.update(:filter => filter)]
    url = case user_id
      when nil, :all then send("#{prefix}project_for_all_path",  args)
      when :me       then send("#{prefix}project_for_me_path",   args.update(:user_id => :me))
      else                send("#{prefix}project_for_user_path", args.update(:user_id => user_id))
    end
    link_to text, url
  end
end
