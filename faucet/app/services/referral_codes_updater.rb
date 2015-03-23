class ReferralCodesUpdater
  class FundedByNotSet < StandardError; end

  def self.set_funded
    Rails.logger.info "#{Time.now} Setting funded referral codes"

    transactions = get_transactions
    return unless transactions.present?
    referral_codes = ReferralCode.where(aasm_state: [:empty, nil]).where(code: [transactions.keys])
    return unless referral_codes

    referral_codes.each do |code|
      trx = transactions[code.code]
      if code.amount == trx[0]['amount'].to_i && code.asset.assetid == trx[0]['asset_id'].to_i
        code.fund do
          code.funded_by = trx[1]
        end
        code.save!
      end
    end
  end

  def self.set_expired
    Rails.logger.info "#{Time.now} Setting expired referral codes"

    funded_codes = ReferralCode.where("expires_at < ?", DateTime.now).where(aasm_state: :funded)
    funded_codes.each do |code|
      code.update_attribute(:aasm_state, 'expired')
      self.refund(code)
    end

    ReferralCode.where("expires_at < ?", DateTime.now).where.not(aasm_state: :expired).update_all(aasm_state: 'expired')
  end

  def self.refund(referral_code)
    raise FundedByNotSet unless referral_code.funded_by
    Rails.logger.info "#{Time.now} Refunding referral code #{referral_code.code}"

    #Account should be already added to contact?
    #account = referral_code.user.bts_accounts.where(name: referral_code.funded_by).first
    #add_contact_account(account.name, account.key)
    transfer(referral_code, referral_code.funded_by, "referral code #{referral_code.code} refund")
    referral_code.close!
  end

  def self.redeem(referral_code, to_account_name)
    return unless referral_code.sent? || referral_code.funded?
    Rails.logger.info "#{Time.now} Redeeming referral code #{referral_code.code}"

    res = transfer(referral_code, to_account_name, "REF #{referral_code.code}")
    return res if res.try(:error)

    referral_code.close! do
      referral_code.update_attributes(redeemed_at: Time.now.to_s(:localdb))
    end
    return {}
  end

  private

  def self.get_transactions
    Rails.logger.info "#{Time.now} Getting #{Rails.application.config.bitshares.faucet_refcode_prefix} transactions history"

    transaction_history = BitShares::API::Wallet.account_transaction_history
    transactions = transaction_history.each_with_object({}) do |transaction, hash|
      entry = transaction['ledger_entries'][0]
      memo = entry['memo']
      next unless memo.start_with?(Rails.application.config.bitshares.faucet_refcode_prefix)

      hash[memo] = [entry['amount'], entry['from_account']]
    end
    Rails.logger.info "------- transactions -----> #{transactions}"
    transactions
  rescue Errno::ECONNREFUSED => ex
    Rails.logger.error "Error! can't get list of transactions: connection refused"
    {}
  end

  def self.transfer(referral_code, to_account_name, message)
    BitShares::API::Wallet.transfer referral_code.amount/referral_code.asset.precision, referral_code.asset.symbol, Rails.application.config.bitshares.bts_faucet_account, to_account_name, message
  rescue Errno::ECONNREFUSED => ex
    Rails.logger.error "Error! can't transfer referral code id##{referral_code.id}: connection refused"
    {error: ex['message']}
  rescue BitShares::API::Rpc::Error => ex
    Rails.logger.error "Error! can't transfer referral code id##{referral_code.id}: #{ex['message']}"
    {error: 'connection refused'}
  end

  def self.add_contact_account(account_name, public_key)
    begin
      BitShares::API::Wallet.add_contact_account(account_name, public_key)
    rescue BitShares::API::Rpc::Error => ex
      if ex.to_s =~ /Account name is already registered/
        account_name = "#{account_name}-cpn-#{self.id}"
        BitShares::API::Wallet.add_contact_account(account_name, public_key)
      else
        raise ex
      end
    rescue Errno::ECONNREFUSED => ex
      Rails.logger.error "Error! can't add contact account: connection refused"
    end
    return account_name
  end

end
