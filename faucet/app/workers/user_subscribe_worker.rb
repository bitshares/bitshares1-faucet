class UserSubscribeWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(user_id, status)
    user = User.find(user_id)
    user.subscribe(status)
  end
end
