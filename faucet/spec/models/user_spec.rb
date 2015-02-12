require 'rails_helper'

describe User do
  describe "#find_for_oauth" do
    subject(:user) { login_with_oauth }

    it "should confirm real email" do
      expect(user.email).to eq('mail@mail.com')
      expect(user.confirmed?).to eq(true)
    end

    it "should copy pending_registration from session" do
      expect(user.pending_intention[:pending_registration]).to eq({account_name: 'name', account_key: 'key'})
    end
  end

  describe "#after_confirmation" do
    it "should set subscription job" do
      user = create(:user)
      expect { user.after_confirmation }.to change(UserSubscribeWorker.jobs, :size).by(1)
    end
  end

  def login_with_oauth
    auth = OmniAuth::AuthHash.new(
        {
            "provider" => "linkedin", "uid" => "123",
            "info" => {"name" => "Username", email: "mail@mail.com"}
        }
    )
    pending_registration = {account_name: 'name', account_key: 'key'}
    User.find_for_oauth(auth, nil, nil, pending_registration)
  end

end
