class CreateHelp < ActiveRecord::Migration
  def self.up
    create_table :help do |t|
      t.string :name
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :help
  end
end
