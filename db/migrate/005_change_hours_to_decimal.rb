class ChangeHoursToDecimal < ActiveRecord::Migration
  def self.up
    change_column :statuses, :hours, :decimal, :precision => 8, :scale => 2, :default => 0.0
  end

  def self.down
    change_column :statuses, :hours, :integer, :default => 0.0
  end
end
