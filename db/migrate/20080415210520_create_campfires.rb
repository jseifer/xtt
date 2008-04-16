class CreateCampfires < ActiveRecord::Migration
  def self.up
    create_table :campfires do |t|
      t.string :domain
      t.string :login
      t.string :password
      t.string :room
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :campfires
  end
end
