class ReferralRegistrator
  attr_reader :user_name, :email, :referral_code

  def initialize(referral_code, email)
    @user_name = referral_code.user.name
    @referral_code = referral_code
    @email = email
  end

  def send_referral_mail
    return { error: 'Referral code is not funded yet' } unless referral_code.state == 'funded'

    referral_code.sent_to = email
    referral_code.login_hash = generate_login_hash

    if referral_code.valid?
      referral_code.save
    else
      return { error: referral_code.errors.full_messages.first }
    end

    if UserMailer.referral_code_email(user_name, email, amount, login_link).deliver
      @referral_code.update_attribute(:state, 'sent')
    else
      { error: 'E-mail with referral code was not send, please try again' }
    end
  end

  private

  def generate_login_hash
    SecureRandom.urlsafe_base64(8).upcase
  end

  def login_link
    "#{Rails.application.routes.url_helpers.referral_login_profile_referral_codes_url}?login_hash=#{referral_code.login_hash}&email=#{email}"
  end

  def amount
    "#{referral_code.asset_amount} #{referral_code.asset.symbol}"
  end
end
