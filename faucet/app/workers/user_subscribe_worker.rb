class UserSubscribeWorker
  include Sidekiq::Worker

  def perform(user_id, status)
    user = User.find(user_id)
    user.subscribe(status)
  end
end
