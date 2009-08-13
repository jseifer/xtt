class User
  include AASM
  aasm_initial_state :pending
  aasm_state :passive
  aasm_state :pending, :enter => :make_activation_code
  aasm_state :active,  :enter => :do_activate
  aasm_state :suspended
  aasm_state :deleted, :enter => :do_delete

  aasm_event :register do
    transitions :from => :passive, :to => :pending, :guard => Proc.new {|u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  aasm_event :activate do
    transitions :from => [:pending, :passive], :to => :active 
  end
  
  aasm_event :suspend do
    transitions :from => [:passive, :pending, :active], :to => :suspended
  end
  
  aasm_event :delete do
    transitions :from => [:passive, :pending, :active, :suspended], :to => :deleted
  end

  aasm_event :unsuspend do
    transitions :from => :suspended, :to => :active,  :guard => Proc.new {|u| !u.activated_at.blank? }
    transitions :from => :suspended, :to => :pending, :guard => Proc.new {|u| !u.activation_code.blank? }
    transitions :from => :suspended, :to => :passive
  end
    
  def reset_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  protected
    def make_activation_code
      self.deleted_at = nil
      reset_activation_code if activation_code.blank?
    end
    
    def do_delete
      self.deleted_at = Time.now.utc
    end

    def do_activate
      self.activated_at = Time.now.utc
      self.deleted_at = self.activation_code = nil
    end
end