class AddSubscribedStatusToUsers < ActiveRecord::Migration
  def change
    add_column(:users, :newsletter_subscribed, :boolean)
  end
end
