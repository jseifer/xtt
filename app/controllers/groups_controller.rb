class GroupsController < ApplicationController
  before_filter :find_group, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  def index
    @groups = Group.find(:all)
  end

  def show
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      flash[:notice] = 'Group was successfully created.'
      redirect_to @group
    else
      render :action => 'new'
    end
  end

  def edit
  end

  def update
    if @group.update_attributes(params[:group])
      flash[:notice] = 'Group was successfully updated.'
      redirect_to @group
    else
      render :action => 'edit'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end

protected
  def find_group
    @group = Group.find(params[:id])
  end
  
  def authorized?
    logged_in? && (admin? || @group.nil? || @group.users.include?(current_user))
  end
end
