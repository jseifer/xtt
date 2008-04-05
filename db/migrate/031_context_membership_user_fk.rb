class ContextMembershipUserFk < ActiveRecord::Migration
  def self.up
    add_column :memberships, :context_id, :integer
  end

  def self.down
    remove_column :contexts, :context_id
  end
end
