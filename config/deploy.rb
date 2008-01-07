set :application, "micromanage"
set :repository,  "git@activereload.net:lh-time.git"
set :deploy_to, "/var/rails/#{application}"
set :scm, :git

set :deploy_via, "copy"

role :app, "two"
role :web, "two"
role :db,  "two", :primary => true

namespace :deploy do
  task :restart do
  end

  task :start do
  end

  task :stop do
  end
end