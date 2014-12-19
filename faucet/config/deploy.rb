require 'mina/git'
require 'mina/bundler'
require 'mina/rsync'

set :domain, 'faucet'
set :user, 'bts'

set :rsync_options, %w[
  --recursive --delete --delete-excluded
  --exclude .git*
  --exclude /config/bitshares.yml
config/secrets.yml
]

task :deploy do
  deploy do
    invoke "rsync:deploy"
  end
end

task :restart do
  queue 'sudo service restart apache'
end
