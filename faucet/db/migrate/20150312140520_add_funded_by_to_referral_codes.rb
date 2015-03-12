class AddFundedByToReferralCodes < ActiveRecord::Migration
  def change
    add_column(:referral_codes, :funded_by, :string)
  end
end
