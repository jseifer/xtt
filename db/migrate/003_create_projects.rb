class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
      t.string :name
      t.boolean :billable
      t.timestamps
    end
    
    add_column :statuses, :project_id, :integer
  end

  def self.down
    drop_table :projects
    remove_column :statuses, :project_id
  end
end
