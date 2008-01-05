class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses, :force => true do |t|
      t.integer :user_id
      t.integer :hours, :default => 0
      t.string :message
      t.string :state
      t.timestamps
    end
    add_index :statuses, [:created_at, :user_id]
  end

  def self.down
    drop_table :statuses
  end
end
