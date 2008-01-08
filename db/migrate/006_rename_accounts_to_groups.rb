class RenameAccountsToGroups < ActiveRecord::Migration
  def self.up
    remove_index :accounts, :name => :index_accounts_on_host
    rename_column :accounts, :host, :name
    rename_table :accounts, :groups
    
    remove_index "projects", :name => "index_projects_on_name_and_account_id"
    rename_column :projects, :account_id, :group_id
    add_index "projects", ["name", "group_id"], :name => "index_projects_on_name_and_group_id"
    
    remove_index "users", :name => "index_users_on_login_and_account_id"
    rename_column :users, :account_id, :group_id
    add_index "users", ["login", "group_id"], :name => "index_projects_on_login_and_group_id"
  end

  def self.down
    rename_table :groups, :accounts
    rename_column :accounts, :name, :host
    add_index "accounts", ["host"], :name => "index_accounts_on_host"
    
    remove_index "projects", :name => "index_projects_on_name_and_group_id"
    rename_column :projects, :group_id, :account_id
    add_index "projects", ["name", "account_id"], :name => "index_projects_on_name_and_account_id"
    
    remove_index "users", :name => "index_projects_on_login_and_group_id"
    rename_column :users, :group_id, :account_id
    add_index "users", ["login", "account_id"], :name => "index_projects_on_login_and_account_id"
  end
end
