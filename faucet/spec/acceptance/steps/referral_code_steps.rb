module ReferralCodeSteps
  step "I see my profile" do
    create :asset, symbol: :USD, precision: 10000
    visit profile_path
  end

  step "I create new referral code for 1 USD" do
    fill_in :referral_code_amount, with: 1
    select 'USD', from: :referral_code_asset_id
    click_button 'Create'
  end

  step "I fund it" do
    referral_code = ReferralCode.last
    referral_code.funded_by = 'some_user'
    referral_code.fund!
    visit current_path
  end

  step "I send it" do
    fill_in :email, with: 'some_email@mail.com'
    click_button 'Send'
  end

  step "I should see 'Email sent'" do
    expect(page).to have_content('Email sent')
  end
end

