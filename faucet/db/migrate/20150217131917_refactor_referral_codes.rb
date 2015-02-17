class RefactorReferralCodes < ActiveRecord::Migration
  def change
    add_column(:referral_codes, :user_id, :integer) unless column_exists?(:referral_codes, :user_id)
    add_column(:referral_codes, :state, :string)
    add_column(:referral_codes, :sent_to, :string)
    add_column(:referral_codes, :login_hash, :string)
    remove_column(:referral_codes, :funded, :boolean)
  end
end
