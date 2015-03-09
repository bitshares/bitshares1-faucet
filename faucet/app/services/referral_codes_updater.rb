class ReferralCodesUpdater
  def self.set_funded
    transactions = get_transactions
    return unless transactions.present?
    codes = ReferralCode.where(aasm_state: [:empty, nil]).where(code: [transactions.keys])
    return unless codes

    codes.each do |code|
      if code.amount == transactions[code.code]['amount'] && code.asset_id == transactions[code.code]['asset_id']
        code.fund
      end
    end
  end

  def self.set_expired
    ReferralCode.where("expires_at < ?", DateTime.now).update_all(aasm_state: 'expired')
  end

  private

  def self.get_transactions
    transaction_history = BitShares::API::Wallet.account_transaction_history
    transactions = transaction_history.each_with_object({}) do |transaction, hash|
      memo = transaction['ledger_entries'][0]['memo']
      next unless memo.start_with?(Rails.application.config.bitshares.faucet_refcode_prefix)
      hash[memo] = transaction['ledger_entries'][0]['amount']
    end
    transactions
  end

end
