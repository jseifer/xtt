class CreateGoals < ActiveRecord::Migration
  def self.up
    create_table :goals do |t|
      t.string :name
      t.integer :hours
      t.datetime :start_date
      t.string  :period
      t.integer :user_id
      t.integer :goal_watching_id
      t.string  :goal_watching_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :goals
  end
end
