class ChangeGroupModel < ActiveRecord::Migration
  def self.up
    remove_index "projects", :name => "index_projects_on_name_and_group_id"
    rename_column :projects, :group_id, :parent_id
    add_column :projects, :parent_type, :string
    Project.update_all "parent_type = 'Group'"
    add_index "projects", ["name", "parent_id", "parent_type"], :name => "index_projects_on_name_and_parent"
    
    remove_index "users", :name => "index_projects_on_login_and_group_id"
    remove_column :users, :group_id
  end

  def self.down
    remove_index "projects", :name => "index_projects_on_name_and_parent"
    rename_column :projects, :parent_id, :group_id
    remove_column :projects, :parent_type
    add_index "projects", ["name", "group_id"], :name => "index_projects_on_name_and_group_id"
    
    add_column :users, :group_id, :integer
    add_index "users", ["login", "group_id"], :name => "index_projects_on_login_and_group_id"
  end
end
