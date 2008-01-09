class GroupProjectsController < ProjectsController
  before_filter :login_required, :only => [:new, :create]

  def index
    @projects = current_user.projects

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @projects }
    end
  end

  def new
    
  end
  
  def create
    
  end
  
  def show
    redirect_to project_path(params[:id])
  end
  
  def edit
    redirect_to edit_project_path(params[:id])
  end
  
  alias_method update  edit
  alias_method destroy edit
end