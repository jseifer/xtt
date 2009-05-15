require 'fastercsv'
class StatusesController < ApplicationController
  before_filter :find_status, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  # USER SCOPE
  
  def index
    @context = Context.new :project_ids => current_user.project_ids, :name => "All projects"

    params[:per] = 9999 if request.format == 'csv'
    @statuses, @date_range = Status.filter(user_status_for(params[:user_id]), params[:filter] ||= :weekly, :context => @context, :date => params[:date], :page => params[:page], :per_page => params[:per]||20)
    @daily_hours = Status.filtered_hours(user_status_for(params[:user_id]), :daily, :context => @context, :date => params[:date])
    @hours       = Status.filtered_hours(user_status_for(params[:user_id]), params[:filter], :context => @context, :date => params[:date])

    all_statuses = Status.filter_all_users(user_status_for(params[:user_id]), params[:filter] ||= :weekly, :context => @context, :date => params[:date])
    # hmm, the [0] is necessary b/c this is actually a WillPaginateCollection
    user_ids = all_statuses[0].map {|s| s.user.permalink }.uniq
    @user_hours = []
    user_ids.each do |user|
      hours = Status.filtered_hours(user_status_for(user), params[:filter], :date => params[:date], :context => @context)
      @user_hours << hours unless hours.empty?
    end
    # reset @user var. hack. omg.
    user_status_for(params[:user_id])

    @context ||= Context.new :name => "etc"
    respond_to do |format|
      format.html # show.html.erb
      format.iphone
      format.xml  { render :xml  => @context }
      format.csv  # show.csv.erb
    end
    
  end

  def last
    @status = current_user.last_status

    respond_to do |format|
      format.xml  { render :xml  => @status }
    end
  end

  def new
    @status = Status.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml  => @status }
    end
  end
  
  def import
    @statuses = []
  end

  def create
    if params[:submit] == 'Out'
      unless params[:status][:code_and_message].blank?
        params[:status][:code_and_message].sub! /@\w*/, ''
        params[:status][:code_and_message].strip!
      end
      params[:status][:code_and_message] = "Out" if params[:status][:code_and_message].blank?
      @status  = current_user.post params[:status][:code_and_message]

    elsif params[:replace] and params[:confirm] == "on" and params[:confirm2] == "on" 
      # Lock up the whole fucking db while we do this really long task! Yeah!!!
      Status.transaction do 
        current_user.backup_statuses!
        Status.delete_all ["user_id=?", current_user.id]
        @statuses = import_statuses(params[:replace])
      end
      flash[:notice] = "Successfully replaced your statuses with #{current_user.statuses.count} new statuses"
      if status = current_user.statuses.find(:first, :order => "created_at desc", :conditions => "created_at is not null")
        status.send :cache_user_status
      end

    elsif params[:import]
      Status.transaction do
        @statuses = import_statuses(params[:import])
      end

    elsif params[:status]
      @status  = current_user.post params[:status][:code_and_message]
    end

    respond_to do |format|
      if @statuses and @statuses.any?
        format.html { render :action => "import" }
        format.xml  {} # FAIL
      elsif @status.nil?
        redirect_to statuses_path
      elsif @status.new_record?
        format.html { render :action => "new" }
        format.xml  { render :xml  => @status.errors, :status => :unprocessable_entity }
      else
        format.html   { redirect_after_status }
        format.iphone { redirect_after_status }
        format.xml  { render :xml  => @status, :status => :created, :location => @status }
      end
    end
  end

  # GLOBAL SCOPE
  include ApplicationHelper
  
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml  => @status }
      format.js   { render :text => nice_time(@status.accurate_time) }
    end
  end

  def update
    respond_to do |format|
      if @status.update_attributes(params[:status])
        flash[:notice] = 'Status was successfully updated.'
        format.html { redirect_to(@status) }
        format.xml  { head :ok }
      else
        format.html { render :action => "show" }
        format.xml  { render :xml  => @status.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @status.destroy
    respond_to do |format|
      format.html { redirect_to(statuses_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def authorized?
    logged_in? && (admin? || @status.nil? || @status.editable_by?(current_user))
  end

  def find_status
    @status = Status.find(params[:id])
  end
  
  def redirect_after_status
    if params[:destination] && params[:destination].first == '/'
      redirect_to params[:destination]
    else
      redirect_to @status.project || root_path
    end
  end

  def import_statuses(data)
    invalid = []
    FasterCSV.parse(data, {:headers=>true}).each do |row|
      next if row['code_and_message'].blank?
      logger.warn row.inspect
      #if row.compact.size == 3
        @status = current_user.post row['code_and_message'], "import"
        @status.update_attributes({ :created_at => Time.parse(row['created_datetime']), :finished_at => Time.parse(row['finished_datetime']), :user_id => current_user.id })
        @status.state ||= 'pending'
        @status.process!
        unless @status.valid?
          invalid << @status
        end
      #else
        # do nothing
      #end
    end
    invalid
  end

  # index
  def user_status_for(status)
    @user = status == 'me' ? current_user : User.find_by_permalink(status)
    @user ? @user.id : nil
  end

end