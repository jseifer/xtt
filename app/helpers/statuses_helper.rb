module StatusesHelper
  def status_summary(project)
    project.nil? ? "is out" : "is working on #{link_to_project project}"
  end
end
