require "rails_helper"

feature 'Omniauth sign in' do
  scenario 'sign in with twitter' do
    visit new_user_session_path
    click_link 'Sign in with Twitter'
    User.last.confirm!

    visit profile_path
    expect(page).to have_content('Please confirm your email address')

    fill_in 'Email', with: 'test@email.ru'
    click_button 'Continue'

    expect(page).to_not have_content('Profile')
    expect(page).to have_content("We've sent you a confirmation link")
  end

  scenario 'sign in with linkedin' do
    visit new_user_session_path
    click_link 'Sign in with LinkedIn'

    expect(page).to have_content('Log in with another identity provider')
  end
end
