server '54.68.28.119:22', :app, :db, primary: true
#server 'db_server:22', :db

#Application settings
set :rails_env, "production"
set :branch, "master"
set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"
set :sidekiq_pid, File.join(shared_path, 'pids', 'sidekiq.pid')

#Database settings
set :database_adapter, "postgresql"
set :database_pool, "25"
set :database_dbname, "trannylogger_prod"
set :database_host, "127.0.0.1"
set :database_user, "deploy"
set :database_pass, "KuVMtgcBCbE6aG6jPpPmCCbz"