class AddPermalinkFields < ActiveRecord::Migration
  def self.up
    remove_index "projects", :name => "index_projects_on_name_and_parent"
    add_index :users, :email
    add_index :users, :identity_url
    add_column :projects, :permalink, :string
    add_column :users, :permalink, :string
    add_column :contexts, :permalink, :string
    add_index :projects, :permalink
    add_index :users, :permalink
    add_index :contexts, :permalink
  end

  def self.down
    remove_index :users, :email
    remove_index :users, :identity_url
    remove_index :projects, :permalink
    remove_index :users, :permalink
    remove_index :contexts, :permalink
    remove_column :projects, :permalink
    remove_column :users, :permalink
    remove_column :contexts, :permalink
    add_index "projects", ["name", "user_id"], :name => "index_projects_on_name_and_parent"
  end
end
