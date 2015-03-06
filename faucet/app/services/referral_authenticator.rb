class ReferralAuthenticator
  attr_reader :login_hash, :email

  def initialize(login_hash, email)
    @login_hash = login_hash
    @email = email
  end

  def login
    referral_code = ReferralCode.where(sent_to: email).first

    return {error: 'Referral code with this E-mail does not exist'} unless referral_code
    return {error: 'Login hash is not correct'} unless referral_code.login_hash == login_hash
    return {error: 'Referral code is expired'} if referral_code.expires_at && referral_code.expires_at < DateTime.now
    return {error: 'Referral code has been already redeemed'} if referral_code.redeemed?

    generated_password = Devise.friendly_token.first(8)
    user = User.new(name: email, email: email, password: generated_password)
    user.skip_confirmation!
    user.save!

    user
  end

end

