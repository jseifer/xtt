class Goal < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :start_date
  validates_presence_of :hours
  validates_presence_of :period
  
  belongs_to :goal_watching, :polymorphic => true

  attr_accessible :name, :start_date, :end_date, :hours, :goal_watching_id, :goal_watching_type, 
    :goal_watching_context_id, :goal_watching_project_id, :goal_watching_user_id, :period
  
  
  validate :must_have_access_to_watching
  
  def must_have_access_to_watching
    logger.warn "checking for #{goal_watching_type} with #{goal_watching_id} for user #{user_id} #{user.login}"
    case goal_watching_type
      when 'Project'
        return if user.project_ids.include?(goal_watching_id)
      when 'Context'
        if user.context_ids.include?(goal_watching_id)
          return
        else
          raise "User contexts are #{user.context_ids.inspect} but we wanted #{goal_watching_id}"
        end
      when 'User'
        return if User.for_project(user.projects).include?(goal_watching)
      end
    errors.add_to_base "You must have access to the thing you're watching!"
  end
  
  # shit there needs to be a better way to do this
  def goal_watching_project_id; goal_watching_id; end
  def goal_watching_context_id; goal_watching_id; end
  def goal_watching_user_id;    goal_watching_id; end
    
  def goal_watching_project_id=(val); self.goal_watching_id=val; self.goal_watching_type = 'Project'; end
  def goal_watching_context_id=(val); self.goal_watching_id=val; self.goal_watching_type = 'Context'; end
  def goal_watching_user_id=(val);    self.goal_watching_id=val; self.goal_watching_type = 'User';    end
end