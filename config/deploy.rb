set :application, "micromanage"
#xset :repository,  "git@activereload.net:lh-time.git"
set :deploy_to, "/var/rails/#{application}"
# set :scm, :git

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
