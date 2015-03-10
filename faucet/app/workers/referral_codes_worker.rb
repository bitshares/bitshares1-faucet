class ReferralCodesWorker
  include Sidekiq::Worker

  def perform
    ReferralCodesUpdater.set_expired
    ReferralCodesUpdater.set_funded
  end
end
