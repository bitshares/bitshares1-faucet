class WelcomeController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:widget]

  def index
    write_referral_cookie(params[:r]) if params[:r]

    if params[:account_name] and (params[:account_key] or params[:active_key])
      @account_name = params[:account_name]
      set_pending_registration(params[:account_name], params[:account_key] || params[:active_key], params[:owner_key])
      redirect_to bitshares_account_path if user_signed_in?
    else
      @account = BtsAccount.new(name: '', key: '')
    end

    @asset = Asset.where(assetid: 0).first
    @faucet_balance = faucet_balance(@asset)
  end

  def account_registration_step2
    @account = BtsAccount.new(bts_account_params)
    logger.debug "BtsAccount: \n #{@account}; #{@account.valid?}; #{@account.errors}"
    set_pending_registration(@account.name, @account.key, nil)

    redirect_to bitshares_account_path if user_signed_in?
  end

  def test_widget
  end

  def refscoreboard
    if request.xhr?
      @refs = BtsAccount.filter(params[:scope]).grouped_by_referrers
      render '_refs', layout: false
    else
      @refs = BtsAccount.grouped_by_referrers
    end
  end

  def bitshares_login
    client_key = params[:client_key]
    server_key = params[:server_key]
    signed_secret = params[:signed_secret]

    rpc_instance = BitShares::API.rpc

    login = rpc_instance.request('wallet_login_finish', [server_key, client_key, signed_secret])
    unless login
      flash[:alert] = 'Sorry, we cannot log you in. Your login session may have expired.'
      return
    end

    blockchain_account = rpc_instance.request('blockchain_get_account', [login['user_account_key']])
    account_name = blockchain_account['name']
    account_key = blockchain_account['owner_key']

    user = current_user

    bts_account = BtsAccount.where(key: account_key).first

    if user and bts_account and user.id != bts_account.user_id
      bts_account.update_attribute(:user_id, user.id)
      bts_account.user = user
    end

    if !user and bts_account
      user = bts_account.user
    end

    unless user
      user = User.create(
          name: account_name,
          email: "#{User::TEMP_EMAIL_PREFIX}-bitshares.com",
          password: Devise.friendly_token[0, 20],
          uid: @uid
      )
    end

    unless bts_account
      BtsAccount.create(name: account_name, key: account_key, user_id: user.id)
    end

    Identity.where(uid: account_key, provider: 'bitshares', user_id: user.id).first_or_create do |i|
      i.uid = account_key
      i.provider = 'bitshares'
      i.user_id = user.id
    end

    sign_in_and_redirect user, :event => :authentication
  end

  private

  def bts_account_params
    params.require(:account).permit(:name, :key)
  end

  def set_pending_registration(account_name, account_key, owner_key)
    if current_user
      current_user.set_pending_registration({'account_name' => account_name, 'account_key' => account_key, 'owner_key' => owner_key})
    else
      session[:pending_registration] = {account_name: account_name, account_key: account_key, owner_key: owner_key}
    end
  end

  def faucet_balance(asset)
    Rails.cache.fetch('key', expires_in: 1.minute) do
      begin
        res = BitShares::API::Wallet.account_balance(Rails.application.config.bitshares.bts_faucet_account)
        return 0 if res.empty?
        res[0][1][0][1]/asset.precision
      rescue BitShares::API::Rpc::Error => ex
        logger.error "Error! can't get faucet's balance: #{ex.message}"
        0
      rescue Errno::ECONNREFUSED => ex
        logger.error "Error! can't get faucet's balance: connection refused"
        0
      end
    end
  end

end
