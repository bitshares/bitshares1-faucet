class RenameStateInReferralCodes < ActiveRecord::Migration
  def change
    rename_column(:referral_codes, :state, :aasm_state)
  end
end
