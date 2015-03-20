class ReferralRegistrator
  attr_reader :user_name, :email, :referral_code

  def initialize(referral_code, email)
    @user_name = referral_code.user.name
    @referral_code = referral_code
    @email = email
  end

  def send_referral_mail
    return { error: 'You need to fund referral code before you can send it' } unless referral_code.funded?

    referral_code.sent_to = email
    referral_code.login_hash = generate_login_hash

    if referral_code.valid?
      referral_code.save
    else
      return { error: referral_code.errors.full_messages.first }
    end
    if UserMailer.referral_code_email(user_name, email, amount, login_link).deliver
      referral_code.set_to_sent!
      referral_code
    else
      { error: "We couldn't send referral code at this time, please try again later or report this error to the faucet owner" }
    end

  end

  private

  def generate_login_hash
    SecureRandom.urlsafe_base64(8).upcase
  end

  def login_link
    "#{Rails.application.routes.url_helpers.referral_login_profile_referral_codes_url}?login_hash=#{referral_code.login_hash}&email=#{email}&code_id=#{referral_code.id}"
  end

  def amount
    "#{referral_code.asset_amount} #{referral_code.asset.symbol}"
  end
end
