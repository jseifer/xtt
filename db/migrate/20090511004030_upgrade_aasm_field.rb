class UpgradeAasmField < ActiveRecord::Migration
  def self.up
    rename_column :statuses, :state, :aasm_state
    rename_column :users, :state, :aasm_state
  end

  def self.down
    rename_column :users, :aasm_state, :state
    rename_column :statuses, :aasm_state, :state
  end
end
