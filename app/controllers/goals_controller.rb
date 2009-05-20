class GoalsController < ApplicationController
  before_filter :find_goal, :only => [:show, :edit, :update, :destroy]
  before_filter :login_required

  def index
    @goals = current_user.goals
  end

  def show
    @goal = current_user.goals.find(params[:id])
  end

  def new
    @goal = Goal.new
  end

  def create
    params[:goal][:start_date].gsub!(/^\w+ /, '')
    params[:goal][:end_date].gsub!(/^\w+ /, '')
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
