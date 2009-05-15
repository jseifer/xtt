class WarningChangeYourCrons < ActiveRecord::Migration
  def self.up
    $stderr.puts <<-STR 
    
    Warning: we've changed the way background jobs are run. You'll need to ensure all your BJ jobs have been completed,
    and add a new cron job to run your Delayed Job (DJ) tasks.  In its simplest sense, this looks like `rake jobs:work`
    Also, modify your deploy script.
STR
    raise "You can comment this line or remove the migration once you have upgraded your background job runner."
  end

  def self.down
  end
end
