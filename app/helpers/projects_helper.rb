module ProjectsHelper
  def link_to_project(project, text = nil, url_for_options = nil)
    link_to h(text || project.name), url_for_options || project
  end
end
