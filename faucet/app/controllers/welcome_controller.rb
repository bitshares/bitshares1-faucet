class WelcomeController < ApplicationController

  def index
    if params[:account_name] and params[:account_key]
      session[:pending_registration] = {account_name: params[:account_name], account_key: params[:account_key]}
      redirect_to bitshares_account_path if user_signed_in?
    end

    @asset = Asset.where(assetid: 0).first
    @faucet_account = Rails.application.config.bitshares.faucet_account
    @faucet_balance = Rails.cache.fetch('key', expires_in: 1.minute) do
      res = BitShares::API::Wallet.account_balance(@faucet_account)
      res[0][1][0][1]/@asset.precision
    end

  end

end
