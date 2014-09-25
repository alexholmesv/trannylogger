# About

Capistrano configuration for Rails application using Thin Server, Sidekiq and RVM at user level.

# Requirements

Ubuntu Server 12.04 LTS, 14.04 LTS, configured with chef for PostgreSQL: [Acid Labs](https://github.com/acidlabs/chef-rails)

# Configure your stages

```ruby
set :stages, %w(production staging)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
```

# Set your application name and domain

```ruby
set :application, "my_app"
set :app_stage, "myapplication.com"
```

# Set your user and group for shell commands

```ruby
set :user, "deploy"
set :group, "deploy"
```

# Set Ruby version and gemset
```ruby
set :rvm_ruby_version, 'ruby-version@gemset'
```

# Set your Git repo

```ruby
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :repository,  "git@gitserver.com:repo.git"
set :ssh_options, { forward_agent: true}
```
To be able to user forward agent, we need to add a config file in our .ssh/ directory:

.ssh/config

```bash
Host app_server
	ForwardAgent yes

Host db_server
	ForwardAgent yes
```

In each server, we have add or modified the following line:

For Ubuntu Server 12.04/14.04: /etc/ssh/sshd_config

```bash
AllowAgentForwarding yes
```
Then we have to restart ssh

If you still can't clone the project check if your key is added to the authentication agent in your machine

```bash
ssh-add ~/.ssh/id_rsa
```

# Configure your stages params

```ruby
server 'app_server:22', :app, :db, primary: true
```

If our servers are configured separately:

```ruby
server 'app_server:22', :app, primary: true
server 'db_server:22', :db
```

# Application settings

```ruby
set :rails_env, "production"
set :branch, "master"
set :deploy_to, "/home/deploy/#{rails_env}.#{app_stage}"
```

# Database settings

```ruby
set :database_adapter, "postgresql"
set :database_username, "postgres"
set :database_password, "postgres"
set :database_pool, "25"
set :database_host, "localhost"
```

# Thin server settings

```ruby
set :server_port, "3000"
set :server_timeout, "30"
set :server_max_conns, "1024"
set :server_max_persistent_conns, "512"
set :server_wait, "30"
set :server_threads, "2"
```

# In case you need to share more directories between releases

You have to add them to `deploy:setup` task before first deploy

```ruby
task :setup, roles: :app do
  run "mkdir -p #{deploy_to}/{releases,shared/{assets,config,log,pids,system}}"
  run "chmod -R g+w #{deploy_to}"
end
```

And then add symlink creation command to `deploy:dir_symlink`

```ruby
task :dir_symlink, roles: :app do
  run "ln -snf #{shared_path}/assets #{latest_release}/public/assets"
  run "ln -snf #{shared_path}/log #{latest_release}/log"
  run "ln -snf #{shared_path}/system #{latest_release}/public/system"
end
```

# Ready to go?

### Don't forget to execute bundle install inside the cap directory.

Now, we need to deploy our application for the first time:

```bash
bundle exec cap <stage> deploy:cold
```

For each deploy, after our first one:

```bash
bundle exec cap <stage> deploy
```
To list the tasks we can execute with Capistrano:

```bash
bundle exec cap -vT
```

We recommend to clean the releases directory periodically:

```bash
bundle exec cap deploy:cleanup -s keep_releases=3 # this command will keep the last 3 releases
```

After each deploy, we run `deploy:auto_cleanup` task. This task will check if we reach the cleanup threshold (20 by default) and run `deploy:cleanup` in that case.

Set the number of releases you want to keep in `deploy.rb` file:

```ruby
#Set number of releases you want to keep after cleanup.
set :keep_releases, 10
```

In case you want to set your own cleanup threshold, you can add `set :cleanup_threshold, <number>` to `deploy.rb` or you can run the task in command line whenever you want:

```bash
bundle exec cap deploy:auto_cleanup -s cleanup_threshold=<number>
```

# Capistrano integration
[Sidekiq](https://github.com/mperham/sidekiq/wiki/Deployment#capistrano)