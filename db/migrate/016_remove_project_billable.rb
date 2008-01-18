class RemoveProjectBillable < ActiveRecord::Migration
  def self.up
    remove_column :projects, :billable
  end

  def self.down
    # eh
  end
end
