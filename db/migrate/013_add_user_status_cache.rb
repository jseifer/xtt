class AddUserStatusCache < ActiveRecord::Migration
  def self.up
    add_column :users, :last_status_project_id, :integer
    add_column :users, :last_status_id, :integer
    add_column :users, :last_status_message, :string
    add_column :users, :last_status_at, :datetime
  end

  def self.down
    remove_column :users, :last_status_project_id
    remove_column :users, :last_status_id
    remove_column :users, :last_status_message
    remove_column :users, :last_status_at
  end
end
