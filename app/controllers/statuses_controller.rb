class StatusesController < ApplicationController
  before_filter :find_status,    :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  # USER SCOPE
  
  def index
    @statuses ||= current_user.statuses

    respond_to do |format|
      format.xml  { render :xml  => @statuses }
    end
  end

  def new
    @status = Status.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @status }
    end
  end

  def create
    @project = current_user.projects.find_by_id params[:status][:project_id] if params[:status][:project_id]
    @status  = current_user.post params[:status][:message], @project

    respond_to do |format|
      if @status.new_record?
        format.html { render :action => "new" }
        format.xml  { render :xml  => @status.errors, :status => :unprocessable_entity }
      else
        #flash[:notice] = 'Status was successfully created.'
        format.html { redirect_to @project || root_path }
        format.xml  { render :xml  => @status, :status => :created, :location => @status }
      end
    end
  end

  # GLOBAL SCOPE
  include ApplicationHelper
  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @status }
      format.js   { render :text => nice_time(@status.accurate_time) }
    end
  end

  def update
    respond_to do |format|
      if @status.update_attributes(params[:status])
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to(@status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @status.destroy

    respond_to do |format|
      format.html { redirect_to(statuses_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def authorized?
    logged_in? && (admin? || @status.nil? || @status.editable_by?(current_user))
  end

  def find_status
    @status = Status.find(params[:id])
  end
end
