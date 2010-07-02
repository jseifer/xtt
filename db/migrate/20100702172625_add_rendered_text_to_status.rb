class AddRenderedTextToStatus < ActiveRecord::Migration
  def self.up
    add_column :statuses, :rendered, :string

    Status.reset_column_information

    Status.all.each do |status|
      status.render_message
      status.save!
    end
  end

  def self.down
    remove_column :statuses, :rendered
  end
end
