require "rails_helper"

describe WelcomeController do
  describe "#refscoreboard" do
    it "should render refs partial on ajax request" do
      expect(xhr :get, :refscoreboard).to render_template('_refs')
    end

    it "should return all records date scope if its not provided" do
      create :bts_account
      xhr :get, :refscoreboard, scope: ''
      expect(assigns(:refs)).to eq(BtsAccount.grouped_by_referrers)
    end
  end

end
