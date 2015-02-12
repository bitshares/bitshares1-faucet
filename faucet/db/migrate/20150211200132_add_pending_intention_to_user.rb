class AddPendingIntentionToUser < ActiveRecord::Migration
  def change
    add_column(:users, :pending_intention, :text, array: true)
  end
end
