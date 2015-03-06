class UserMailer < ApplicationMailer
  def referral_code_email(user_name, email, amount, link)
    @user_name = user_name
    @amount = amount
    @link = link

    mail(
        to: email,
        subject: "Bitshares.org: #{@user_name} sent you money"
    )
  end
end
