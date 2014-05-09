require "bundler/capistrano"
load "deploy/assets"

set :user, 'capistrano'
set :use_sudo, false

set :application, ENV['APP_DOMAIN']
set :applicationdir, "#{application}"

set :scm, :git
set :repository, "TODO"

server "www.example.com", :app, :web, :db, :primary => true

set :deploy_to, "/var/www/#{applicationdir}"
set :deploy_via, :export
set :group_writable, true
set :keep_releases, 3

# For this to work initially, you must run cap deploy:setup which will generate a shared/log/production.log file that is writable by the apache user
# You must also create a shared/config/database.yml file that contains the DB connection settings and shared/config/application.yml with the app settings


before "deploy:assets:precompile" do
	run ["ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
	].join(" && ")
  run ["ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
  ].join(" && ")
end

namespace :deploy do
 task :start do ; end
 task :stop do ; end

 task :migrations do
   desc "Migrating database"
   run "cd #{release_path} && rake db:migrate RAILS_ENV=#{rails_env}"
 end

  task :seed do
   run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
end

after "deploy:update_code", "deploy:migrations"

after "deploy:restart" do
	desc "restart delayed_job"
	run "cd #{current_path}; RAILS_ENV=#{rails_env} script/delayed_job restart"
end