Delayed::Job.class_eval do
  belongs_to :user

  def self.with_user(user)
    if user
      with_scope(:create => {:user_id => user.id}) do
        yield
      end
    else
      yield
    end
  end

  after_save :set_user_error

protected
  def set_user_error
    if user_id && attempts >= 1 && !last_error.blank?
      user.update_attribute :failed_jobs, true
    end
  end
end