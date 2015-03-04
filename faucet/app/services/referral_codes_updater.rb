class ReferralCodesUpdater
  def self.set_funded
    transactions = BitShares::API::Wallet.account_transaction_history
    memos = transactions.each_with_object([]) { |transaction, array| array << transaction['ledger_entries'][0]['memo'] }
    codes = ReferralCode.where(aasm_state: [:ok, nil]).where(code: [memos])
    codes.each { |code| code.fund } if codes
  end

end
