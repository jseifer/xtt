class GroupsController < ApplicationController
  before_filter :find_group, :except => [:index, :new, :create]
  before_filter :login_required
  
  def index
    @groups = current_user.groups

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml  => @groups }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @group }
    end
  end

  def new
    @group = Group.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @group }
    end
  end

  def edit
  end

  def create
    @group = current_user.owned_groups.build(params[:group])

    respond_to do |format|
      if @group.save
        flash[:notice] = 'Group was successfully created.'
        format.html { redirect_to(@group) }
        format.xml  { render :xml  => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml  => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end

  protected
  
  def authorized?
    logged_in? && (admin? || @group.nil? || @group.users.include?(current_user))
  end
  
  def find_group
    @group = Group.find(params[:id])
  end
end
