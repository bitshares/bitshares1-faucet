require 'rails_helper'

describe Profile::ReferralCodesController do
  let(:user) { create :user, :confirmed }
  let(:referral_code) { create :referral_code, :funded, user_id: user.id }

  before do
    sign_in user
  end

  describe "#create" do
    it "should set expires_at time to 24 hours from now when selected" do
      Timecop.freeze(Date.today)
      asset = create :asset
      get :create, referral_code: { expires_at: '24 hours', amount: 1, asset_id: asset.id }

      expect(ReferralCode.last.expires_at).to eq(DateTime.now + 24.hours)
    end
  end

  describe "#send_mail" do
    subject(:send_mail) {
      post :send_mail, id: referral_code.id, email: 'new@email.com'
    }

    it "should send email to referral and set status to sent" do
      expect { send_mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "should set state to sent" do
      ref = create :referral_code, :funded, user_id: user.id
      post :send_mail, id: ref.id, email: 'test@email.com'
      ref.reload

      expect(ref.aasm_state).to eq('sent')
    end

    it "should set pending_codes to true for receiving user" do
      ref = create :referral_code, :funded, user_id: user.id
      post :send_mail, id: ref.id, email: 'test@email.com'
      user.reload

      expect(user.pending_codes).to eq(true)
    end
  end

  describe "#referral_login" do
    it "should create user with email from registration link" do
      ref = create :referral_code, login_hash: 123, sent_to: 'email@email.com', user_id: user.id
      get :referral_login, email: 'email@email.com', login_hash: 123, code_id: ref.id

      expect(User.last.email).to eq('email@email.com')
    end
  end
end
