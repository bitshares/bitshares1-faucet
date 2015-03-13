class ReferralCodesUpdater
  class FundedByNotSet < StandardError; end

  def self.set_funded
    transactions = get_transactions
    return unless transactions.present?
    codes = ReferralCode.where(aasm_state: [:empty, nil]).where(code: [transactions.keys])
    return unless codes

    codes.each do |code|
      memo = transactions[code.code]
      if code.amount == memo[0]['amount'] && code.asset_id == memo[0]['asset_id']
        code.fund do
          code.funded_by = memo[1]
        end
      end
    end
  end

  def self.set_expired
    funded_codes = ReferralCode.where("expires_at < ?", DateTime.now).where(aasm_state: :funded)
    funded_codes.each do |code|
      code.update_attribute(:aasm_state, 'expired')
      self.refund(code)
    end

    ReferralCode.where("expires_at < ?", DateTime.now).where.not(aasm_state: :expired).update_all(aasm_state: 'expired')
  end

  def self.refund(referral_code)
    raise FundedByNotSet unless referral_code.funded_by

    #Account should be already added to contact?
    #account = referral_code.user.bts_accounts.where(name: referral_code.funded_by).first
    #add_contact_account(account.name, account.key)
    transfer(referral_code, "refunding of faucet referral code #{referral_code.code}")
  end

  def self.redeem(referral_code, account_name, public_key)
    return unless referral_code.sent? || referral_code.funded?

    add_contact_account(account_name, public_key)
    transfer(referral_code, "REF #{referral_code.code}")
    referral_code.update_attribute(:redeemed_at, Time.now.to_s(:localdb))
  end

  private

  def self.get_transactions
    transaction_history = BitShares::API::Wallet.account_transaction_history
    transactions = transaction_history.each_with_object({}) do |transaction, hash|
      entry = transaction['ledger_entries'][0]
      memo = entry['memo']
      next unless memo.start_with?(Rails.application.config.bitshares.faucet_refcode_prefix)
      hash[memo] = [entry['amount'], entry['from_account']]
    end
    transactions
  end

  def self.transfer(referral_code, message)
    BitShares::API::Wallet.transfer referral_code.amount/referral_code.asset.precision, referral_code.asset.symbol, Rails.application.config.bitshares.bts_faucet_account, referral_code.funded_by, message
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
    end
    return account_name
  end

end
