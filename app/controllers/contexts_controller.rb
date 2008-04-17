class ContextsController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    redirect_to users_path
  end

  def show
    @statuses, @date_range = @project.statuses.filter(user_status_for(params[:user_id]), params[:filter] ||= :weekly, :date => params[:date], :page => params[:page], :per_page => params[:per]||20)
    @daily_hours = @project.statuses.filtered_hours(user_status_for(params[:user_id]), :daily, :date => params[:date])
    @hours       = @project.statuses.filtered_hours(user_status_for(params[:user_id]), params[:filter], :date => params[:date])
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml  => @project }
      format.csv  # show.csv.erb
    end
  end
end