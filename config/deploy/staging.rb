server 'app_server:22', :app, :db, primary: true
#server 'db_server:22', :db

#Application settings
set :rails_env, "staging"
set :branch, "master"
set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"
set :sidekiq_pid, File.join(shared_path, 'pids', 'sidekiq.pid')

#Database settings
set :database_adapter, "postgresql"
set :database_pool, "25"