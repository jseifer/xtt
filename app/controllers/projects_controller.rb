class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  # /projects - List user projects
  # /groups/:group_id/projects - List group projects
  # /users/:user_id/projects - Invalid, redirect to /projects
  def index
    if params[:user_id]
      redirect_to projects_path and return
    elsif params[:group_id]
      @group = Group.find params[:group_id]
      if admin? || @group.users.include?(current_user)
        @projects = @group.projects
      else
        redirect_to projects_path and return
      end
    else
      @projects = current_user.projects
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @projects }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @project }
    end
  end

  def new
    @project = Project.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @project }
    end
  end

  def edit
  end

  def create
    @parent  = (params[:user_id] && User.find(params[:user_id])) || (params[:group_id] && Group.find(params[:group_id]))
    @project = @parent.projects.build(params[:project])

    respond_to do |format|
      if @project.save
        flash[:notice] = 'Project was successfully created.'
        format.html { redirect_to(@project) }
        format.xml  { render :xml  => @project, :status => :created, :location => @project }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update_attributes(params[:project])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@project) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @project.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

protected
  def find_project
    if params[:user_id] || params[:group_id]
      redirect_to project_path(params[:id])
    else
      @project = Project.find(params[:id])
    end
  end
  
  def authorized?
    logged_in? && (admin? || @project.nil? || @project.editable_by?(current_user))
  end
end
