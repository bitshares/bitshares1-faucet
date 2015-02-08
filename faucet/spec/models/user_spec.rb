require 'rails_helper'

describe User do
  #let(:user) { create :user }

  describe "#find_for_oauth" do
    it "should confirm real email" do
      auth = OmniAuth::AuthHash.new(
          {"provider" => "linkedin", "uid" => "123", "info" => {"name" => "Username", email: "mail@mail.com"}}
      )
      user = User.find_for_oauth(auth, nil, nil)

      expect(user.email).to eq('mail@mail.com')
      expect(user.confirmed?).to eq(true)
    end
  end

  describe "#after_confirmation" do
    it "should set subscription job" do
      #expect { user.after_confirmation }.to change(UserSubscribeWorker.jobs, :size).by(1)
    end
  end

end
