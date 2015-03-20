require 'rails_helper'

describe 'ReferralCodesUpdater' do
  let(:user) { create :user }
  let(:referral_code) { create :referral_code, user_id: user.id, sent_to: user.email, funded_by: 'some_account' }

  describe 'self.redeem' do
    it "should set redeemed_at to Time.now" do
      bts_account = create :bts_account
      referral_code.update_attributes(aasm_state: :sent)
      ReferralCodesUpdater.redeem(referral_code, bts_account.name)

      expect(referral_code.redeemed_at).to eq(Time.now.to_s(:localdb))
    end
  end

  describe 'self.set_expired' do
    it "should refund funded codes" do
      referral_code.update_attributes(aasm_state: :funded, expires_at: DateTime.now - 1.hour)
      ReferralCodesUpdater.set_expired
      referral_code.reload

      expect(referral_code.aasm_state).to eq('expired')
    end
  end

end
