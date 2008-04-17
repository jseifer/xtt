class ContextsController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    redirect_to root_path
  end

  def show
    @context = current_user.contexts.find_by_permalink(params[:id]) unless params[:id].blank?
    @statuses, @date_range = Status.filter(user_status_for(params[:user_id]), params[:filter] ||= :weekly, :context => @context, :date => params[:date], :page => params[:page], :per_page => params[:per]||20)
    @daily_hours = Status.filtered_hours(user_status_for(params[:user_id]), :daily, :context => @context, :date => params[:date])
    @hours       = Status.filtered_hours(user_status_for(params[:user_id]), params[:filter], :context => @context, :date => params[:date])
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml  => @context }
      format.csv  # show.csv.erb
    end
  end

protected
  def user_status_for(status)
    @user = status == 'me' ? current_user : User.find_by_permalink(status)
    @user ? @user.id : nil
  end
end