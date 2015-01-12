require Rails.root.join('lib/BitShares/bitshares_api.rb').to_s

BitShares::API.init(Rails.application.config.bitshares.bts_rpc_port, Rails.application.config.bitshares.bts_rpc_user, Rails.application.config.bitshares.bts_rpc_password, logger: Rails.logger)
