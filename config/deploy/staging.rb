server 'ubuntuservervbox', :app, :db, primary: true

set :rails_env, "staging"
set :branch, "master"

set :database_adapter, "postgresql"
set :database_username, "postgres"
set :database_password, "123456"