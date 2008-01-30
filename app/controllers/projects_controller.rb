class ProjectsController < ApplicationController
  before_filter :find_project, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  def index
    @projects ||= current_user.projects

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @projects }
    end
  end

  def show
    @statuses = @project.statuses.filter(user_status_for(params[:user_id]), params[:filter])
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

  def create
    @project ||= current_user.owned_projects.build(params[:project])

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

  def edit
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
    @project = Project.find(params[:id])
  end
  
  def authorized?
    logged_in? && (admin? || @project.nil? || @project.editable_by?(current_user))
  end
  
  def user_status_for(status)
    case status
      when 'me'    then current_user.id
      when /^\d+$/ then status.to_i
      else nil
    end
  end
end
