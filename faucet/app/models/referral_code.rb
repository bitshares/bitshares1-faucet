class ReferralCode < ActiveRecord::Base
  belongs_to :asset

  before_create :generate_code
  validates :code, presence: true
  validates :amount, presence: true
  validates :asset_id, presence: true

  before_validation(on: :create) do
    generate_code()
    logger.debug "after_validation: #{self.inspect}"
    a = Asset.find(self.asset_id)
    self.amount *= a.precision
  end

  def asset_amount
    self.amount / asset.precision
  end

  def redeem(account_name, public_key)
    if status() == 'ok'
      account_name = add_contact_account(account_name, public_key)
      #BitShares::API::Wallet.account_register(account_name, 'angel')
      BitShares::API::Wallet.transfer(self.amount / asset.precision, asset.symbol, 'angel', account_name, "REF #{self.code}")
      #BitShares::API::Wallet.transfer_to_address(self.amount / asset.precision, asset.symbol, 'angel', public_key, "CPN #{self.code}")
      update_attribute(:redeemed_at, Time.now.to_s(:db))
    end
  end

  def generate_code
    self.code = "#{Rails.application.config.bitshares.faucet_refcode_prefix}-#{SecureRandom.urlsafe_base64(8).upcase}"
  end

  def status
    return @status if @status
    @status = if !self.code
                'notfound'
              elsif self.redeemed_at
                'redeemed'
              elsif self.expires_at and self.expires_at < DateTime.now
                'expired'
              else
                'ok'
              end
    return @status
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
