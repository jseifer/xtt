class GroupStatusesController < StatusesController
  skip_before_filter :find_status
  prepend_before_filter :find_group, :only => :index

  def index
    @statuses = @group.statuses
    super
  end
  
  def new
    redirect_to new_status_path
  end
  
  def show
    redirect_to status_path(params[:id])
  end
  
  def edit
    redirect_to edit_status_path(params[:id])
  end
  
  alias create  new
  alias update  edit
  alias destroy edit

protected
  def find_group
    @group = Group.find params[:group_id]
  end

  def authorized?
    logged_in? && (admin? || (@group && @group.users.include?(current_user)))
  end
end