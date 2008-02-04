class StatusFinishTime < ActiveRecord::Migration
  def self.up
    add_column :statuses, :finished_at, :datetime
  end

  def self.down
    remove_column :statuses, :finished_at
  end
end
