class StatusSource < ActiveRecord::Migration
  def self.up
    add_column :statuses, :source, :string, :default => "the web"
  end

  def self.down
    remove_column :statuses, :source
  end
end
