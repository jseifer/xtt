class CreateTendrils < ActiveRecord::Migration
  def self.up
    create_table :tendrils do |t|
      t.integer :project_id
      t.string :notifies_type
      t.integer :notifies_id

      t.timestamps
    end
  end

  def self.down
    drop_table :tendrils
  end
end
