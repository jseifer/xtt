class GoalsController < ApplicationController
  before_filter :find_goal, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required
  
  helper :projects

  def index
    @goals = current_user.goals
  end

  def show
    @goal = current_user.goals.find(params[:id])

    @hours = case @goal.goal_watching_type
      when 'Project'
        @goal.goal_watching.statuses.filtered_hours(current_user.id, @goal.period, :date => @goal.start_date)
      when 'Context'
        @context = @goal.goal_watching

        all_statuses = Status.filter_all_users(nil, @goal.period, :context => @context, :date => @goal.start_date)
        user_ids = all_statuses[0].map {|s| s.user_id }.uniq
        @user_hours = []
        user_ids.each do |user|
          hours = Status.filtered_hours(user, @goal.period, :date => @goal.start_date, :context => @context)
          @user_hours << hours unless hours.empty?
        end
        @user_hours
      else
        raise
      end
  end

  def new
    @goal = Goal.new
  end

  def create
    params[:goal][:start_date].gsub!(/^\w+ /, '')
    params[:goal_watching_id] = params[:'goal_watching_#{params[:goal_watching_type].downcase}_id']
    @goal = current_user.goals.build(params[:goal])

    respond_to do |format|
      if @goal.save
        flash[:notice] = 'Goal was successfully created.'
        format.html { redirect_to(@goal) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def edit
  end

  def update
    params[:goal_watching_id] = params[:'goal_watching_#{params[:goal_watching_type].downcase}_id']

    respond_to do |format|
      if @goal.update_attributes(params[:goal])
        flash[:notice] = 'Goal was successfully updated.'
        format.html { redirect_to(@goal) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @goal.destroy

    respond_to do |format|
      format.html { redirect_to(goals_url) }
      format.xml  { head :ok }
      format.json { head :ok }
    end
  end
protected

  def find_goal
    @goal = current_user.goals.find params[:id]
  end
end
