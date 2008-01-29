class UsersController < ApplicationController
  before_filter :find_user, :only => [:show, :edit, :update, :suspend, :unsuspend, :destroy, :purge]
  before_filter :login_required,       :only => [:index, :show, :edit, :update]
  before_filter :admin_required,       :only => [:suspend, :unsuspend, :destroy, :purge]

  # private user dashboard 
  def index
  end

  # user status page
  def show
    @status = @user.statuses.latest
  end

  # user signup
  def new
    @user = User.new
  end

  # user signup
  def create
    cookies.delete :auth_token
    @user = User.new(params[:user])
    @user.register! if @user.valid?
    if @user.errors.empty?
      self.current_user = @user
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!"
    else
      render :action => 'new'
    end
  end

  # user activation
  def activate
    self.current_user = params[:activation_code].blank? ? :false : User.find_by_activation_code(params[:activation_code])
    if current_user != :false && !current_user.active?
      current_user.activate!
      flash[:notice] = "Signup complete!"
    end
    redirect_back_or_default('/')
  end
  
  # private user editing
  def edit
  end
  
  # private user editing
  def update
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'Project was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml  => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # admin only
  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  # admin only
  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  # admin only
  def destroy
    @user.delete!
    redirect_to users_path
  end

  # admin only
  def purge
    @user.destroy
    redirect_to users_path
  end

protected
  def find_user
    @user = User.find(params[:id])
  end
  
  def authorized?
    return false unless logged_in?
    return true if admin?
    @user.nil? || @user == current_user
  end
end
