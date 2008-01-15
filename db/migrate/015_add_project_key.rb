class AddProjectKey < ActiveRecord::Migration
  class Project < ActiveRecord::Base
  end
  def self.up
    add_column :projects, :code, :string
    transaction do
      Project.find(:all).each do |project|
        Project.update_all ['code = ?', project.name.gsub(/\W/, '').downcase], ['id = ?', project.id]
      end
    end
  end

  def self.down
    remove_column :projects, :code
  end
end
