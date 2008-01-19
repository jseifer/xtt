set :application, "micromanage"
set :repository,  "git@activereload.net:lh-time.git"
set :deploy_to, "/var/rails/#{application}"
set :scm, :git

set :deploy_via, "copy"

role :app, "two"
role :web, "two"
role :db,  "two", :primary => true

task :after_update_code, :roles => :app do
  put(File.read('config/database.yml'), "#{release_path}/config/database.yml", :mode => 0444) 
  run <<-CMD
    cd #{release_path} && rake tmp:create
  CMD
  run "ln -s #{shared_path}/mongrel_cluster.yml #{release_path}/config/"
end

namespace :deploy do
  task :restart do
    run "cd #{release_path} && mongrel_rails cluster::restart"
  end

  task :start do
  end

  task :stop do
  end
end

desc "Backup (mysqldump) production database and rsync to local box"
task :backup, :roles => :db, :only => { :primary => true } do
  # The on_rollback handler is only executed if this task is executed within
  # a transaction (see below), AND it or a subsequent task fails.
  filename = "/tmp/#{application}.dump.#{Time.now.to_f}.sql.bz2"
  yaml = YAML::load_file('config/database.yml')
  text = capture "cat #{current_path}/config/database.yml"
  yaml = YAML::load(text)
  conf = yaml['production']
  
  on_rollback { delete filename }

  run "mysqldump -u #{conf['username']} -p -h #{conf['host'] || '127.0.0.1'} #{conf['database']} --ignore-table=#{conf['database']}.sessions | bzip2 -c > #{filename}" do |ch, stream, out|
    ch.send_data "#{conf['password']}\n" if out =~ /^Enter password:/
  end

  `mkdir -p #{File.dirname(__FILE__)}/../backups`
  `rsync #{roles[:db][0].host}:#{filename} #{File.dirname(__FILE__)}/../backups/`
  run "rm -f #{filename}"
  
  backup_public_dir
end
