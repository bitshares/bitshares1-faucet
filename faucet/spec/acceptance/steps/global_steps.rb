step "I am signed in" do
  user = create :user
  login_as user, run_callbacks: false
  user.confirm!
end
