class Goal < ActiveRecord::Base
  belongs_to :user
  
  validates_presence_of :start_date
  validates_presence_of :end_date
  validates_presence_of :hours
  
  belongs_to :goal_watching, :polymorphic => true

  attr_accessible :name, :start_date, :end_date, :hours, :goal_watching_id, :goal_watching_type, 
    :goal_watching_context_id, :goal_watching_project_id, :goal_watching_user_id
  
  
  validate :must_have_access_to_watching
  
  def must_have_access_to_watching
    logger.warn "checking for #{goal_watching_type} with #{goal_watching_id}"
    case goal_watching_type
      when 'Project'
        return if user.projects.include?(goal_watching)
      when 'Context'
        return if user.contexts.include?(goal_watching)
      when 'User'
        return if User.for_project(user.projects).include?(goal_watching)
      end
    errors.add_to_base "You must have access to the thing you're watching!"
  end
  
  # shit there needs to be a better way to do this
  def goal_watching_project_id; goal_watching_id; end
  def goal_watching_context_id; goal_watching_id; end
  def goal_watching_user_id;    goal_watching_id; end
    
  def goal_watching_project_id=(val); self.goal_watching_id=val; end
  def goal_watching_context_id=(val); self.goal_watching_id=val; end
  def goal_watching_user_id=(val);    self.goal_watching_id=val; end
end