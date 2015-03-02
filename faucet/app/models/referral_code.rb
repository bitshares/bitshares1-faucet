class ReferralCode < ActiveRecord::Base
  include AASM

  aasm do
    state :ok, initial: true
    state :sent
    state :funded
    state :redeemed
    state :expired

    event :fund do
      transitions from: :ok, to: :funded
    end

    event :set_to_sent do
      transitions from: :funded, to: :sent
    end

  end

  EXPIRED_AT = ['1 hour', '2 hours', '6 hours', '12 hours', '24 hours', '2 days', '3 days', '7 days']
  AVAILABLE_ASSETS = Asset.where(symbol: [:USD, :CNY, :EUR, :GOLD, :SILVER]).pluck(:symbol, :id)

  belongs_to :asset
  belongs_to :user

  validates :user_id, presence: true
  validates :code, presence: true
  validates :amount, presence: true, numericality: true
  validates :asset_id, presence: true
  validates :sent_to, uniqueness: true, on: :update

  def aasm_state
    self[:aasm_state] || :ok
  end

  def self.generate_code
    "#{Rails.application.config.bitshares.faucet_refcode_prefix}-#{SecureRandom.urlsafe_base64(8).upcase}"
  end

  def asset_amount
    self.amount / asset.precision
  end

  def redeem(account_name, public_key)
    return unless self.sent? || self.funded?

    account_name = add_contact_account(account_name, public_key)
    #BitShares::API::Wallet.account_register(account_name, 'angel')
    BitShares::API::Wallet.transfer(self.amount / asset.precision, asset.symbol, 'angel', account_name, "REF #{self.code}")
    #BitShares::API::Wallet.transfer_to_address(self.amount / asset.precision, asset.symbol, 'angel', public_key, "CPN #{self.code}")
    update_attribute(:redeemed_at, Time.now.to_s(:db))
  end

  def set_expires_at(expires_at)
    return Time.now unless expires_at.in?(EXPIRED_AT)

    case expires_at
      when '1 hour'
        DateTime.now + 1.hour
      when '2 hours'
        DateTime.now + 2.hours
      when '6 hours'
        DateTime.now + 6.hours
      when '12 hours'
        DateTime.now + 12.hours
      when '24 hours'
        DateTime.now + 24.hours
      when '2 days'
        DateTime.now + 2.days
      when '3 days'
        DateTime.now + 3.days
      when '7 days'
        DateTime.now + 7.days
    end
  end

  private

  def add_contact_account(account_name, public_key)
    begin
      BitShares::API::Wallet.add_contact_account(account_name, public_key)
    rescue BitShares::API::Rpc::Error => ex
      if ex.to_s =~ /Account name is already registered/
        account_name = "#{account_name}-cpn-#{self.id}"
        BitShares::API::Wallet.add_contact_account(account_name, public_key)
      else
        raise ex
      end
    end
    return account_name
  end

end
