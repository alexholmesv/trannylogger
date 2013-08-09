server 'ubuntuservervbox', :app, :db, primary: true

set :rails_env, "production"
set :branch, "prod"

set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"

set :database_adapter, "postgresql"
set :database_username, "postgres"
set :database_password, "123456"

set :server_port, "3000"
set :server_timeout, "30"
set :server_max_conns, "1024"
set :server_max_persistent_conns, "512"
set :server_wait, "30"
set :server_threads, "2"