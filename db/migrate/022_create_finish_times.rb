class CreateFinishTimes < ActiveRecord::Migration
  def self.up
    Status.transaction do 
      Status.find(:all).each do |status|
        status.update_attribute :finished_at, status.followup_time if status.followup
      end
    end
  end

  def self.down
  end
end
