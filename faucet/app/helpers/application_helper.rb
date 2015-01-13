module ApplicationHelper

  def bitshares_login_url
    begin
      res = BitShares::API.rpc.request('wallet_login_start', [Rails.application.config.bitshares.bts_faucet_account])
    rescue
      return nil
    end
    uri = URI.parse(request.original_url)
    callback_address = (uri.port.to_i == 80 ? uri.host : "#{uri.host}:#{uri.port}") + "/bitshares_login"
    return res + callback_address
  end

  def has_identity?(provider)
    current_user and current_user.identities.find_by(provider: provider)
  end

end
