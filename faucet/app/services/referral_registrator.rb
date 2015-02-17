class ReferralRegistrator
  def initialize(user, referral_code, email)
    @user = user
    @referral_code = referral_code
    @email = email
  end

  def send_mail
    if update_referral_code
      amount = "#{@referral_code.asset_amount} #{@referral_code.asset.symbol}"
      link = "#{@referral_code.login_hash}" #todo: add referral_login path

      if UserMailer.referral_code_email(@user.name, @email, amount, link).deliver
        @referral_code.update_attribute(:state, 'sent')
      end
    end
  end

  def update_referral_code
    @referral_code.sent_to = @email
    @referral_code.login_hash = generate_login_link
    @referral_code.save
  end

  def generate_login_link
    SecureRandom.urlsafe_base64(8).upcase
  end
end
