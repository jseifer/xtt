namespace :tt do
  task :notify => :environment do
    status = Status.find ENV['STATUS']
    status.project.tendrils.each do |tendril|
      tendril.notifies.send_message "[XTT] #{status.user.login} is now '#{status.message}' on #{status.project.name}"
    end
  end

end