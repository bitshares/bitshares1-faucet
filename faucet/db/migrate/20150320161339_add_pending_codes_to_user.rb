class AddPendingCodesToUser < ActiveRecord::Migration
  def change
    add_column :users, :pending_codes, :boolean
  end
end
