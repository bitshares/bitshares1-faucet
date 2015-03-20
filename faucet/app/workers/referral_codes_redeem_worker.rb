class ReferralCodesRedeemWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(referral_code_id, account_name)
    referral_code = ReferralCode.find(referral_code_id)
    ReferralCodesUpdater.redeem(referral_code, account_name)
  end
end
