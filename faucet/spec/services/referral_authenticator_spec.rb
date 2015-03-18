require 'rails_helper'

describe 'ReferralAuthenticator' do

  describe '#login' do
    it "should return existing user if it exists" do
      user = create :user, email: 'some_email@email.com'
      create :referral_code, login_hash: 'some_login_hash', sent_to: 'some_email@email.com', user_id: user.id

      expect(ReferralAuthenticator.new('some_login_hash', 'some_email@email.com').login).to eq(user)
    end
  end
end
