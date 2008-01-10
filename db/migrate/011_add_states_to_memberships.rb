class AddStatesToMemberships < ActiveRecord::Migration
  def self.up
    add_column :memberships, :state, :string, :default => 'passive'
    add_column :memberships, :deleted_at, :datetime
  end

  def self.down
    remove_column :memberships, :state
    remove_column :memberships, :deleted_at
  end
end
