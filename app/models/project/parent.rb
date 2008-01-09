module Project::Parent
  def self.included(base)
    base.has_many :memberships, :dependent => :delete_all
    base.has_many :projects, :order => 'name',  :dependent => :destroy, :as => :parent
  end
end