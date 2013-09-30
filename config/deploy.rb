#Configure your stages
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#Set your application name and domain
set :application, "my_app"
set :app_stage, "myapplication.com"

#Set your user and group for shell commands
set :user, "deploy"
set :group, "deploy"

#Set your Git repo
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :repository,  "git@gitserver.com:repo.git"
set :deploy_via, :remote_cache
set :ssh_options, { forward_agent: true}

namespace :deploy do
  desc "Create and set permittions for capistrano directory structure."
	task :setup, roles: :app do
    run "mkdir -p #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
    run "chmod g+w #{deploy_to} #{deploy_to}/releases #{deploy_to}/shared #{deploy_to}/shared/system #{deploy_to}/shared/log #{deploy_to}/shared/pids"
	end

  desc "Clone project in a new release path and install gems in Gemfile."
  task :update_release, roles: :app do
    run "git clone #{repository} -b #{branch} #{deploy_to}/releases/#{release_name} && cd #{deploy_to}/releases/#{release_name} && bundle install --without development test"
  end

  desc "Updates the symlink to the most recently deployed version."
  task :create_symlink, roles: :app, :except => { :no_release => true } do
    on_rollback do
      if previous_release
        run "rm -f #{current_path}; ln -s #{previous_release} #{current_path}; true"
      else
        logger.important "no previous release to rollback to, rollback of symlink skipped"
      end
    end

    run "rm -f #{current_path} && ln -s #{latest_release} #{current_path}"
  end

  desc "Create database yaml in shared path."
  task :db_configure, roles: :app do
    db_config = <<-EOF
#{rails_env}:
  adapter:  #{database_adapter}
  database: #{application}_#{rails_env}
  host:     #{database_host}
  pool:     #{database_pool}
  username: #{database_username}
  password: #{database_password}
EOF

    run "rm -Rf #{shared_path}/config && mkdir -p #{shared_path}/config"
    put db_config, "#{shared_path}/config/database.yml"
  end

  desc "Create thin configuration yaml in shared path."
  task :thin_configure, roles: :app do
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
onebyone:             true
EOF

    run "rm -Rf #{shared_path}/thin && mkdir -p #{shared_path}/thin"
    put thin_config, "#{shared_path}/thin/server.yml"
  end

  desc "Make symlink for database yaml."
  task :db_symlink, roles: :app do
    run "ln -snf #{shared_path}/config/database.yml #{current_path}/config/database.yml"
  end

  desc "Configuring database for project."
  task :db_setup, roles: :app do
    run "cd #{current_path} && bundle exec rake db:setup RAILS_ENV=#{rails_env}"
  end

  desc "Start Thin server."
  task :start, roles: :app do
    run "cd #{current_path} && bundle exec thin start -C #{shared_path}/thin/server.yml"
  end

  desc "Stop Thin server."
  task :stop, roles: :app do
    run "cd #{current_path} && bundle exec thin stop -C #{shared_path}/thin/server.yml"
  end

  desc "Restart Thin server."
  task :restart, roles: :app do
    run "cd #{current_path} && bundle exec thin restart -C #{shared_path}/thin/server.yml"
  end

  desc "First time deploy."
	task :cold do
    update_release
    db_configure
    db_symlink
    db_setup
    rake.migrate
    rake.assets
    thin_configure
    foreman.setup
  end

  desc "Deploys you application."
  task :default do
    update_release
    db_symlink
    rake.migrate
    rake.assets
    restart
  end
end

namespace :rake do
  desc "Run assets:precompile rake task for the deployed application."
  task :assets, roles: :app do
    run "cd #{current_path} && bundle exec rake assets:precompile RAILS_ENV=#{rails_env} RAILS_GROUPS=assets"
  end

  desc "Run the migrate rake task."
  task :migrate, roles: :app do
    run "cd #{current_path} && bundle exec rake RAILS_ENV=#{rails_env} db:migrate"
  end
end

namespace :rails do
  desc "Open the rails console on one of the remote servers."
  task :console, roles: :app do
    hostname = find_servers_for_task(current_task).first
    port = exists?(:port) ? fetch(:port) : 22
    exec "ssh -l #{user} #{hostname} -p #{port} -t '#{current_path}/script/rails c #{rails_env}'"
  end
end

namespace :foreman do
  desc "Create executable scripts for application server handle"
  task :setup, roles: :app do
    procfile = <<-EOF
web: cd #{current_path} && bundle exec thin start -C #{shared_path}/thin/server.yml
worker: cd #{current_path} && bundle exec sidekiq -e #{rails_env} -P #{sidekiq_pid}
EOF

    run "rm -Rf #{shared_path}/foreman && mkdir -p #{shared_path}/foreman"
    put procfile, "#{shared_path}/foreman/Procfile"
    run "cd #{current_path} && bundle exec foreman start -f #{shared_path}/foreman/Procfile"
    run "cd #{current_path} && #{sudo} foreman export upstart /etc/init -f #{shared_path}/foreman/Procfile -a #{rails_env}.#{app_stage} -u #{user}"
    monitor
  end

  desc "Start upstart monitoring"
  task :monitor, roles: :app do
    run "#{sudo} start #{rails_env}.#{app_stage}"
  end

  desc "Stop upstart monitoring"
  task :unmonitor, roles: :app do
    run "#{sudo} stop #{rails_env}.#{app_stage}"
  end
end

before "deploy:cold", "deploy:setup"
before "deploy:stop", "foreman:unmonitor"
after "deploy:update_release", "deploy:create_symlink"
after "deploy:start", "foreman:monitor"