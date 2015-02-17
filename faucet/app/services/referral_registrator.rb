class ReferralRegistrator
  attr_reader :user_name, :email, :referral_code

  class ReferralCodeUpdateError < StandardError; end

  def initialize(referral_code, email)
    @user_name = referral_code.user.name
    @referral_code = referral_code
    @email = email
  end

  def send_mail
    if update_referral_code
      if UserMailer.referral_code_email(user_name, email, amount, login_link).deliver
        @referral_code.update_attribute(:state, 'sent')
      end
    else
      raise ReferralCodeUpdateError, 'Referral Code has not been updated'
    end
  end

  private

  def update_referral_code
    return false if referral_code.state == 'sent'

    referral_code.sent_to = email
    referral_code.login_hash = generate_login_hash
    referral_code.save
  end

  def generate_login_hash
    SecureRandom.urlsafe_base64(8).upcase
  end

  def login_link
    # todo: fix this
    Rails.application.routes.default_url_options = Rails.application.config.action_mailer.default_url_options

    "#{Rails.application.routes.url_helpers.users_referral_login_url}?login_hash=#{referral_code.login_hash}&email=#{email}"
  end

  def amount
    "#{referral_code.asset_amount} #{referral_code.asset.symbol}"
  end
end
