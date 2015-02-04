require 'rails_helper'

describe User do
  let(:user) { create :user }

  describe "#after_confirmation" do
    it "should set subscription job" do
      #expect { user.after_confirmation }.to change(UserSubscribeWorker.jobs, :size).by(1)
    end
  end

end
