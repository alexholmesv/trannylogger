set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "tarotronic"
set :app_stage, "tarotronic.com"

set :user, "deploy"
set :group, "deploy"

set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :repository,  "git@gitlab.acid.cl:tarotronic.git"
set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"
set :deploy_via, :remote_cache
set :ssh_options, { forward_agent: true}

role :app, "ubuntuservervbox"
role :db, "ubuntuservervbox"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end

namespace :deploy do
  desc "Create and set permittions for capistrano directory structure."
	task :setup do
    run "mkdir -p #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
    run "chmod g+w #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
	end

  desc "Clone project in a new release path and install gems in Gemfile."
  task :update_release do
    run "git clone #{repository} -b #{branch} #{deploy_to}/releases/#{release_name} && cd #{deploy_to}/releases/#{release_name} && bundle install --without development test"
  end

  desc "Create database yaml in shared path."
  task :db_configure do
    db_config = <<-EOF
#{rails_env}:
  adapter:  #{database_adapter}
  database: "#{application}_#{rails_env}"
  pool:     25
  username: #{database_username}
  password: #{database_password}
EOF

    run "rm -Rf #{shared_path}/config && mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

  desc "Create thin configuration yaml in shared path."
  task :thin_configure do
    thin_config = <<-EOF
---
chdir:                #{current_path}
environment:          #{rails_env}
address:              0.0.0.0
port:                 #{server_port}
timeout:              #{server_timeout}
log:                  #{shared_path}/log/thin.log
pid:                  #{shared_path}/pids/thin.pid
max_conns:            #{server_max_conns}
max_persistent_conns: #{server_max_persistent_conns}
require:              []

wait:                 #{server_wait}
servers:              #{server_threads}
daemonize:            true
EOF

    run "rm -Rf #{shared_path}/thin && mkdir -p #{shared_path}/thin"
    put thin_config, "#{shared_path}/thin/server.yml"
  end

  desc "Make symlink for database yaml."
  task :db_symlink do
    run "ln -snf #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end

  desc "Configuring database for project."
  task :db_setup do
    run "cd #{current_path} && bundle exec rake db:setup RAILS_ENV=#{rails_env}"
  end

  desc "Start Thin server."
  task :start do
    run "cd #{current_path} && bundle exec thin start -C #{shared_path}/thin/server.yml"
  end

  desc "Stop Thin server."
  task :stop do
    run "cd #{current_path} && bundle exec thin stop -C #{shared_path}/thin/server.yml"
  end

  desc "Restart Thin server."
  task :restart do
    run "cd #{current_path} && bundle exec thin restart -C #{shared_path}/thin/server.yml"
  end

  desc "First time deploy"
	task :cold do
    update_release
    db_configure
    db_symlink
    db_setup
    migrate
    rake:assets
    thin_configure
    start
  end
end

namespace :rake do
  desc "Run assets:precompile rake task for the deployed application."
  task :assets do
    run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env} RAILS_GROUPS=assets"
  end
end

namespace :rails do
  desc "Open the rails console on one of the remote servers"
  task :console do
    hostname = find_servers_for_task(current_task).first
    port = exists?(:port) ? fetch(:port) : 22
    exec "ssh -l #{user} #{hostname} -p #{port} -t '#{current_path}/script/rails c #{rails_env}'"
  end
end

before "deploy:cold", "deploy:setup"

after "deploy:update_release", "deploy:create_symlink"