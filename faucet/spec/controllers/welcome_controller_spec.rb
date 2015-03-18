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

  describe "#index" do
    before do
      user = create :user, :confirmed
      sign_in user
    end

    #it "should set pending registration" do
    #  get :index, account_name: 'name', account_key: 123
    #
    #  expect(subject.current_user.pending_intention).to eq({:pending_registration=>{"account_name"=>"name", "account_key"=>"123", "owner_key"=>nil}})
    #end

  end

end
