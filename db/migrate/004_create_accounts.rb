class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :host
      t.timestamps
    end
    
    add_column :projects, :account_id, :integer
    add_column :users,    :account_id, :integer
    add_index :users,    [:login, :account_id]
    add_index :projects, [:name, :account_id]
    add_index :accounts, :host
  end

  def self.down
    drop_table :accounts
    remove_index :users,    [:login, :account_id]
    remove_index :projects, [:name, :account_id]
    remove_index :accounts, :host
    remove_column :projects, :account_id
    remove_column :users,    :account_id
  end
end
