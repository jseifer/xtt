class IndexProjectCode < ActiveRecord::Migration
  def self.up
    add_index "projects", ["code"]
  end

  def self.down
    remove_index "projects", ["code"]
  end
end
