class MembershipsController < ApplicationController
  before_filter :load_project
  before_filter :login_required
  
  def create
    @user = User.find(params[:user_id])
    @membership = Membership.create(:project => @project, :user => @user)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @membership = Membership.find(params[:id])
    @user = @membership.user
    @membership.destroy

    respond_to do |format|
      format.js
    end
  end
  
protected
  def load_project
    @membership = Membership.find(params[:id]) if params[:id]
    @project = @membership ? @membership.project : Project.find(params[:project_id])
  end
  
  def authorized?
    logged_in? && (admin? || @project.users.include?(current_user))
  end
end
