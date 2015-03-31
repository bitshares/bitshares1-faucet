require Rails.root.join('lib/BitShares/bitshares_api.rb').to_s

BitShares::API.init(APPCONFIG.bts_rpc_port, APPCONFIG.bts_rpc_user, APPCONFIG.bts_rpc_password, logger: Rails.logger, instance_name: 'btsrpc')
