class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.string :code
      t.string :email
      t.string :project_ids
      t.timestamps
    end
    
    add_index :invitations, :code
  end

  def self.down
    remove_index :invitations, :code
    drop_table :invitations
  end
end
