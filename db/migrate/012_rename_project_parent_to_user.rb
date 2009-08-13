class RenameProjectParentToUser < ActiveRecord::Migration
  class Project < ActiveRecord::Base
  end

  def self.up
    Project.update_all ['parent_id = ?', 1], ['parent_type = ?', 'Group']
    remove_index  :projects, :name => 'index_projects_on_name_and_parent'
    remove_column :projects, :parent_type
    rename_column :projects, :parent_id, :user_id
  end

  def self.down
  end
end
