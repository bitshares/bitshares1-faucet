class ReferralCodesWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform
    ReferralCodesUpdater.set_expired
    ReferralCodesUpdater.set_funded
  end
end
