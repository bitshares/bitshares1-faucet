require 'rails_helper'

describe UsersController do
  let(:user) { create(:user) }

  before(:each) do
    sign_in user
  end

  describe "#finish_signup" do
    it "should render template with form to fill in email" do
      expect(get :finish_signup).to render_template('finish_signup')
    end

    it "should add email to unconfirmed" do
      patch :finish_signup, user: {email: 'new@email.com'}
      user.reload
      expect(user.unconfirmed_email).to eq('new@email.com')
    end

    it "sends confirmation email" do
      expect { patch :finish_signup, user: {email: 'new@email.com'} }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#subscribe" do
    before(:each) do
      user.confirm!
    end

    it "should unsubscribe subscribed user" do
      subject.current_user.newsletter_subscribed = true
      xhr :get, :subscribe
      expect(subject.current_user.newsletter_subscribed).to eq(false)
    end

    it "should subscribe unsubscribed user" do
      subject.current_user.newsletter_subscribed = false
      xhr :get, :subscribe
      expect(subject.current_user.newsletter_subscribed).to eq(true)
    end
  end
end
