class UserAimName < ActiveRecord::Migration
  def self.up
    add_column :users, :aim_login, :string
  end

  def self.down
    remove_column :users, :aim_login
  end
end
