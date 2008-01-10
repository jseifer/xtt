class MembershipsController < ApplicationController
  before_filter :load_group
  before_filter :login_required
  
  def create
    @user = User.find(params[:user_id])
    @membership = Membership.create(:group => @group, :user => @user)

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
  def load_group
    @membership = Membership.find(params[:id]) if params[:id]
    @group = @membership ? @membership.group : Group.find(params[:group_id])
  end
  
  def authorized?
    logged_in? && (admin? || @group.users.include?(current_user))
  end
  
end
