class ContextsController < ApplicationController
  before_filter :login_required, :except => :index

  def index
    redirect_to root_Path
  end

  def show
    @context = current_user.contexts.find_by_permalink(params[:id]) unless params[:id].blank?
    @statuses, @date_range = Status.filter(@context, params[:filter] ||= :weekly, :date => params[:date], :page => params[:page], :per_page => params[:per]||20)
    @daily_hours = Status.filtered_hours(@context, :daily, :date => params[:date])
    @hours       = Status.filtered_hours(@context, params[:filter], :date => params[:date])
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml  => @context }
      format.csv  # show.csv.erb
    end
  end
end