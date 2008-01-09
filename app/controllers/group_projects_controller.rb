class GroupProjectsController < ProjectsController
  skip_before_filter :find_project
  prepend_before_filter :find_group,  :only => [:index, :new, :create]

  def index
    @projects = @group.projects
    super
  end

  # inherit
  # def new
  
  def create
    @project ||= @group.projects.build(params[:project])
    super
  end
  
  def show
    redirect_to project_path(params[:id])
  end
  
  def edit
    redirect_to edit_project_path(params[:id])
  end
  
  alias update  edit
  alias destroy edit

protected
  def find_group
    @group = Group.find params[:group_id]
  end
  
  def authorized?
    logged_in? && (admin? || @group.owner == current_user)
  end
end