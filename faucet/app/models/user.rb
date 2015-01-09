class User < ActiveRecord::Base
  has_many :identities
  has_many :bts_accounts
  has_many :widgets

  TEMP_EMAIL_PREFIX = 'change@me'
  TEMP_EMAIL_REGEX = /\Achange@me/

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable
  devise :omniauthable, :omniauth_providers => [:facebook, :twitter, :linkedin, :google_oauth2, :github, :reddit, :weibo, :qq]

  validates_format_of :email, :without => TEMP_EMAIL_REGEX, on: :update
  validates :name, presence: true
  validates :password, presence: true, length: { minimum: 6 }
  validates_confirmation_of :password

  def self.find_for_oauth(auth, signed_in_resource, uid)
    #logger.debug "\n-----> auth:\n#{auth.to_yaml}"
    identity = Identity.find_for_oauth(auth)
    user = signed_in_resource ? signed_in_resource : identity.user

    if user.nil?
      email_is_verified = auth.info.email #&& (auth.info.verified || auth.info.verified_email)
      email = auth.info.email if email_is_verified
      user = User.where(:email => email).first if email

      # Create the user if it's a new registration
      if user.nil?
        user = User.new(
          name: auth.info.name || auth.extra.raw_info.name,
          email: email ? email : "#{TEMP_EMAIL_PREFIX}-#{auth.uid}-#{auth.provider}.com",
          password: Devise.friendly_token[0,20],
          uid: uid
        )
        #user.skip_confirmation!
        user.save!
      end
    end

    # Associate the identity with the user if needed
    if identity.user != user
      identity.user = user
      identity.save!
    end

    user
  end

  def register_account(account_name, account_key, referrer=nil)
    logger.debug "---------> registering account #{account_name}, key: #{account_key}"
    sleep(0.4) # this is to prevent bots abuse
    account = self.bts_accounts.where(name: account_name).first
    result = { account_name: account_name }
    if account
      result[:error] = "Account '#{account_name}' is already registered"
      return result
    end
    if self.bts_accounts.count >= Rails.application.config.bitshares.registrations_limit
      result[:error] = 'Account cannot be registered. You are running out of your limit of free account registrations.'
      return result
    end
    begin
      BitShares::API::Wallet.add_contact_account(account_name, account_key)
      BitShares::API::Wallet.account_register(account_name, Rails.application.config.bitshares.faucet_account)
      self.bts_accounts.create(name: account_name, key: account_key, referrer: referrer)
    rescue BitShares::API::Rpc::Error => ex
      result[:error] = ex.to_s
      logger.error("!!! Error. Cannot register account #{account_name} - #{ex.to_s}")
    end
    return result
  end

end
