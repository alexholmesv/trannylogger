server 'ubuntuservervbox', :app, :db, primary: true

set :rails_env, "production"
set :branch, "prod"

set :database_adapter, "postgresql"
set :database_username, "postgres"
set :database_password, "123456"
