server 'app_server:22', :app, :db, primary: true
#server 'db_server:22', :db

#Application settings
set :rails_env, "production"
set :branch, "master"
set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"

#Database settings
set :database_adapter, "postgresql"
set :database_pool, "25"

#Thin server settings
set :server_port, "3000"
set :server_timeout, "30"
set :server_max_conns, "1024"
set :server_max_persistent_conns, "512"
set :server_wait, "30"
set :server_threads, "2"