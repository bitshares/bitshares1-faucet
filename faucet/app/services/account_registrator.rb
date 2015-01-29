class AccountRegistrator
  def initialize(user, account)
    @user = user
    @account = account
  end

  def register(account_name, account_key, referrer)
    @result = {account_name: account_name}

    if @account
      @result[:error] = "Account '#{account_name}' is already registered"
      return @result
    end

    if @user.bts_accounts.count >= Rails.application.config.bitshares.registrations_limit
      @result[:error] = 'Account cannot be registered. You are running out of your limit of free account registrations.'
      return @result
    end

    begin
      account_key.start_with?('DVS') ? register_dvs(account_name, account_key) : register_bts(account_name, account_key)
      user.bts_accounts.create(name: account_name, key: account_key, referrer: referrer)
    rescue BitShares::API::Rpc::Error => ex
      @result[:error] = ex.to_s
      logger.error("!!! Error. Cannot register account #{account_name} - #{ex.to_s}")
    end
    @result
  end

  private

  def register_bts(account_name, account_key)
    BitShares::API::Wallet.add_contact_account(account_name, account_key)
    BitShares::API::Wallet.account_register(account_name, Rails.application.config.bitshares.bts_faucet_account)
  end

  def register_dvs(account_name, account_key)
    dvs_rpc_instance = BitShares::API::Rpc.new(Rails.application.config.bitshares.dvs_rpc_port, Rails.application.config.bitshares.dvs_rpc_user, Rails.application.config.bitshares.dvs_rpc_password, logger: Rails.logger)

    dvs_rpc_instance.request('wallet_add_contact_account', [account_name, account_key])
    dvs_rpc_instance.request('wallet_account_register', [account_name, Rails.application.config.bitshares.dvs_faucet_account])
  end

end
