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

end