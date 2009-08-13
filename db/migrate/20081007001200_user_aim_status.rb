class UserAimStatus < ActiveRecord::Migration
  def self.up
    add_column :users, :aim_status, :string
  end

  def self.down
    remove_column :users, :aim_status
  end
end
