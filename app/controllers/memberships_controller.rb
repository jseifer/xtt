class MembershipsController < ApplicationController
  before_filter :load_group
  
  def create
    @membership = Membership.new(params[:membership])

    respond_to do |format|
      if @membership.save
        format.js
      else
        format.js
      end
    end
  end

  def destroy
    @membership = Membership.find(params[:id])
    @membership.destroy

    respond_to do |format|
      format.js
    end
  end
  
  protected
  def load_group
    @group = current_user.groups.find(params[:group_id])
  end
  
end
