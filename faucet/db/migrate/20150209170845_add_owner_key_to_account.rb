class AddOwnerKeyToAccount < ActiveRecord::Migration
  def change
    add_column(:bts_accounts, :owner_key, :string)
    add_column(:dvs_accounts, :owner_key, :string)
  end
end
