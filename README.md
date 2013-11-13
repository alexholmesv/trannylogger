# Requirements

Ubuntu Server 12.04 LTS, configured with chef for PostgreSQL: [Acid Labs](https://github.com/acidlabs/chef-rails)

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

# Set your Git repo

```ruby
set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
set :repository,  "git@gitserver.com:repo.git"
set :deploy_via, :remote_cache
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

For Ubuntu Server 12.04: /etc/ssh/sshd_config

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

# Using RVM
If you installed RVM in your server, you need to do the following

* Add `rvm-capistrano` to your Gemfile and `bundle install`
* Require it in your deploy configuration `require 'rvm/capistrano'`
* If you are using a system wide installation set the rvm_type variable `set :rvm_type, :system`

# Ready to go?

### Don't forget to execute bundle install inside the cap directory.

Now, we need to deploy our application for the first time:

```bash
cap <stage> deploy:cold
```

For each deploy, after our first one:

```bash
cap <stage> deploy
```

With our application running, we can start/stop our upstart daemon, monitoring thin in server terminal:

```bash
sudo start/stop <application_upstart>
```

If we want to stop our server, we have to stop upstart daemon first.

To list the task we can execute with Capistrano:

```bash
cap -vT
```

We recommend to clean the releases directory periodically:

```bash
cap deploy:cleanup -s keep_releases=3 # this command will keep the last 3 releases
```

# Capistrano integration
[Sidekiq](https://github.com/mperham/sidekiq/wiki/Deployment#capistrano)