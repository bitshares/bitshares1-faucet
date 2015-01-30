require 'rails_helper'

describe UsersController do
  let(:user) { create(:user) }

  before(:each) do
    sign_in user
    user.confirm!
  end

  describe "#finish_signup" do
    it "should render template with form to fill in email" do
      expect(get :finish_signup, id: user.id).to render_template('finish_signup')
    end

    it "should add email to uncofirmed" do
      patch :finish_signup, id: user.id, user: {email: 'new@email.com'}
      user.reload
      expect(user.unconfirmed_email).to eq('new@email.com')
    end

    it "sends confirmation email" do
      expect { patch :finish_signup, id: user.id, user: {email: 'new@email.com'} }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
