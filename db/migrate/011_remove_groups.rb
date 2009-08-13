class RemoveGroups < ActiveRecord::Migration
  class Project < ActiveRecord::Base
    belongs_to :parent, :polymorphic => true
  end
  class Group < ActiveRecord::Base
    has_many :projects, :as => :parent, :class_name => "RemoveGroups::Project"
  end
  class Membership < ActiveRecord::Base
  end

  def self.up
    memberships = Membership.find :all
    groups      = Group.find(memberships.collect(&:group_id).uniq).index_by(&:id)
    projects    = groups.values.inject({}) { |p, g| p.update g.id => Project.find_all_by_parent_id_and_parent_type(g.id, "Group") }

    drop_table :groups
    rename_column :memberships, :group_id, :project_id
    transaction do
      say_with_time "Deleting Memberships" do
        Membership.delete_all
      end
      
      memberships.each do |m|
        projects[m.group_id].each do |p|
          say_with_time "Granting User #{m.user_id} access to Project #{p.id} in Group #{p.parent_id}" do
            m = ::Membership.new :user_id => m.user_id, :project_id => p.id
            m.save_without_validation
          end
        end
      end
    end
  end

  def self.down
  end
end
