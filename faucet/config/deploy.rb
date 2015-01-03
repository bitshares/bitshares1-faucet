require 'mina/git'
require 'mina/bundler'

set :domain, 'faucet'
set :user, 'bts'
set :deploy_to, '/www'
set :repository, 'https://github.com/BitShares/web_services.git'

task :deploy do
  deploy do
    invoke :'git:clone'
    #invoke :'bundle:install'
  end
end

task :restart do
  queue 'sudo service restart nginx'
end
