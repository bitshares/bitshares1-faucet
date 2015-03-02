require 'rails_helper'

describe Profile::ReferralCodesController do
  let(:user) { create :user, :confirmed }
  let(:referral_code) { create :referral_code, user_id: user.id, aasm_state: 'ok' }

  before do
    sign_in user
  end

  describe "#create" do
    it "should set expires_at time to 24 hours from now when selected" do
      time_now = DateTime.parse("Feb 25 2015")
      Timecop.freeze(time_now)
      asset = create :asset
      get :create, referral_code: { expires_at: '24 hours', amount: 1, asset_id: asset.id }

      expect(ReferralCode.last.expires_at).to eq(DateTime.now + 24.hours)
    end
  end

  describe "#send_mail" do
    subject(:send_mail) {
      referral_code.update_attribute(:aasm_state, 'funded')
      post :send_mail, id: referral_code.id, email: 'new@email.com'
    }

    it "should send email to referral and set status to sent" do
      expect { send_mail }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    #it "should set state to sent" do
    #  ref = create :referral_code, user_id: user.id, aasm_state: 'funded'
    #  post :send_mail, id: ref.id, email: 'new@email.com'
    #
    #  expect(ref.aasm_state).to eq('sent')
    #end

    it "should not sent email if the state of referral code not equal funded" do
      change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  describe "#referral_login" do
    it "should create user with email from registration link" do
      create :referral_code, login_hash: 123, sent_to: 'email@email.com', user_id: user.id
      get :referral_login, email: 'email@email.com', login_hash: 123

      expect(User.last.email).to eq('email@email.com')
    end
  end

  describe "#after_referral_login" do
    it "should allow referred users to see this page" do
      referral_code.sent_to = 'test@email.com'
      referral_code.save

      expect(get :after_referral_login).to_not redirect_to(root_path)
    end
  end

  #describe "#redeem" do
  #  it "should set redeemed_at to Time.now" do
  #    request.env["HTTP_REFERER"] = Rails.application.config.bitshares.default_url
  #    bts_account = create :bts_account
  #    referral_code.update_attributes(sent_to: user.email, aasm_state: :sent)
  #    post :redeem, account: bts_account.name, code: referral_code.code
  #
  #    expect(referral_code.redeemed_at).to eq(Time.now)
  #  end
  #end

end
