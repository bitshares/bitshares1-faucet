require 'mina/git'
require 'mina/bundler'
require 'mina/rails'
require 'mina/rvm'

set :domain, 'faucet'
set :user, 'bts'
set :deploy_to, '/www'
set :repository, 'https://github.com/BitShares/web_services.git'
set :shared_paths, ['config/bitshares.yml', 'config/secrets.yml']

task :environment do
  invoke :'rvm:use[ruby-2.1.3@default]'
end

task deploy: :environment do
  deploy do
    invoke :'git:clone'
    #invoke :'deploy:link_shared_paths'
    #invoke :'bundle:install'
    #invoke :'rails:db_migrate'
    #invoke :'rails:assets_precompile'
  end
end

task :restart do
  queue 'sudo service restart nginx'
end
