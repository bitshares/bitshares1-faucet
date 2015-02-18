class ReferralAuthenticator
  attr_reader :login_hash, :email

  def initialize(login_hash, email)
    @login_hash = login_hash
    @email = email
  end

  def login
    return unless ReferralCode.find_by(sent_to: email).login_hash == login_hash

    generated_password = Devise.friendly_token.first(8)
    user = User.new(name: email, email: email, password: generated_password)
    user.skip_confirmation!
    user.save!

    user
  end

end

