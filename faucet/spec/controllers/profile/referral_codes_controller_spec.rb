require 'rails_helper'

describe Profile::ReferralCodesController do
  let(:user) { create :user, :confirmed }
  let(:referral_code) { create :referral_code, user_id: user.id }

  before do
    sign_in user
  end

  describe "#send_mail" do
    subject(:send_mail) { post :send_mail, id: referral_code.id, email: 'new@email.com' }

    it "should send email to referral and set status to sent" do
      expect { send_mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should set status to sent" do
      send_mail
      referral_code.reload
      expect(referral_code.state).to eq('sent')
    end
  end

end
