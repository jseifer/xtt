namespace :tt do
  task :notify => :environment do
    status = Status.find ENV['STATUS']
    project = status.project

    if project.nil? # don't send a message
      if status.previous.project 
        project = status.previous.project
      end
    end
    
    if project
      project.tendrils.each do |tendril|
        if status.out?
          previous = status.previous
          tendril.notifies.send_message "[XTT] #{status.user.login} is out, and no longer working on #{status.previous.project.name}: '#{status.message}'"
        else
          project = status.previous.project
          if project && project != status.project
            tendril.notifies.send_message "[XTT] #{status.user.login} switched projects, and is now \"#{status.message}\" on #{status.project.name}"
          elsif project.nil?
            tendril.notifies.send_message "[XTT] #{status.user.login} is back, \"#{status.message}\" on #{status.project.name}"
          else
            tendril.notifies.send_message "[XTT] #{status.user.login} is now \"#{status.message}\" still on #{status.project.name}"
          end
        end
      end
    end
  end
end