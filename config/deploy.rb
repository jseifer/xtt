set :application, "xtt"
set :repository,  "git@entp:tt.git"
set :deploy_to, "/var/www/#{application}"
set :scm, :git
set :rails_version, 8872
set :branch, "origin/production"

# set :deploy_via, "copy"

role :app, "entp.com:30187"
role :web, "entp.com:30187"
role :db,  "entp.com:30187", :primary => true

task :after_update_code, :roles => :app do
  run <<-CMD
    cd #{release_path} &&
    ln -s #{shared_path}/config/mongrel_cluster.yml #{release_path}/config/ && 
    ln -s #{shared_path}/config/database.yml        #{release_path}/config/ && 
    rake tmp:create &&
    sudo rake edge REVISION=#{rails_version} RAILS_PATH=/var/www/#{application}/shared/rails
  CMD
end

namespace :deploy do
  task :restart do
    run "cd #{current_path} && sudo mongrel_rails cluster::restart"
  end

  task :start do
    run "cd #{current_path} && sudo mongrel_rails cluster::start"
  end

  task :stop do
    run "cd #{current_path} && sudo mongrel_rails cluster::stop"
  end
end

desc "Backup (mysqldump) production database and rsync to local box"
task :backup, :roles => :db, :only => { :primary => true } do
  # The on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  filename = "/tmp/#{application}.dump.#{Time.now.to_f}.sql.bz2"
  text = capture "cat #{current_path}/config/database.yml"
  yaml = YAML::load(text)
  conf = yaml['production']
  
  on_rollback { delete filename }

  run "mysqldump -u #{conf['username']} -p -h #{conf['host'] || '127.0.0.1'} #{conf['database']} --ignore-table=#{conf['database']}.sessions | bzip2 -c > #{filename}" do |ch, stream, out|
    ch.send_data "#{conf['password']}\n" if out =~ /^Enter password:/
  end

  `mkdir -p #{File.dirname(__FILE__)}/../backups`
  `rsync #{roles[:db].servers[0].host}:#{filename} -e 'ssh -p 30187' #{File.dirname(__FILE__)}/../backups/`
  run "rm -f #{filename}"

  yaml = YAML::load_file('config/database.yml')
  conf = yaml['development']
  puts conf.inspect
  filename.gsub!("/tmp", "./backups")
  puts "Loading data from #{filename} into *local* development DB"
  puts "Executing `bunzip2 -c #{filename} | mysql5 -u #{conf['username']} -h #{conf['host'] || '127.0.0.1'} -p #{conf['database']}`"
  `bunzip2 -c #{filename} | mysql -u #{conf['username']} -h #{conf['host']} -p #{conf['database']}`

#  backup_public_dir
end
