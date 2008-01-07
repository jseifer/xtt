class StatusesController < ApplicationController
  before_filter :login_required
  before_filter :find_record, :only => :index
  before_filter :find_user,   :only => [:new, :create]
  before_filter :find_status, :only => [:show, :update, :destroy]

  # USER SCOPE
  
  def index
    @statuses = @record.statuses

    respond_to do |format|
      format.html # index.html.erb
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
    @status = @user.statuses.build(params[:status])

    respond_to do |format|
      if @status.save
        flash[:notice] = 'Status was successfully created.'
        format.html { redirect_to(@user) }
        format.xml  { render :xml  => @status, :status => :created, :location => @status }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @status.errors, :status => :unprocessable_entity }
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
  def find_record
    @record = 
      if params[:user_id]
        find_user
      elsif params[:project_id]
        @project = Project.find(params[:project_id])
      else
        raise ActiveRecord::RecordNotfound
      end
  end
  
  def find_user
    @user = User.find(params[:user_id])
  end
  
  # skip anon users for specs
  # login_required has your back
  def find_status
    @status = Status.find(params[:id])
    !logged_in? || @status.editable_by?(current_user) || access_denied
  end
end
