class ReferralCode < ActiveRecord::Base
  include AASM

  aasm do
    state :empty, initial: true
    state :sent
    state :funded
    state :redeemed
    state :expired
    state :closed

    event :fund do
      transitions from: :empty, to: :funded
    end

    event :set_to_sent do
      transitions from: :funded, to: :sent
      after do
        update_pending_codes_status(true)
      end
    end

    event :close do
      transitions from: [:funded, :sent, :expired], to: :closed
      after do
        update_pending_codes_status(false)
      end
    end

  end

  EXPIRED_AT = ['1 hour', '2 hours', '6 hours', '12 hours', '24 hours', '2 days', '3 days', '7 days']

  BASE_ASSET_SYMBOL = Rails.env.production? ? :BTS : :XTS
  AVAILABLE_ASSETS = Asset.where(symbol: [BASE_ASSET_SYMBOL, :USD, :CNY, :EUR, :GOLD, :SILVER]).pluck(:symbol, :id)

  belongs_to :asset
  belongs_to :user

  validates :user_id, presence: true
  validates :code, presence: true
  validates :amount, presence: true, numericality: true
  validates :asset_id, presence: true
  validates :sent_to, email: true, on: :update, allow_nil: true
  validates :funded_by, presence: true, on: :update
  validates :expires_at, presence: true

  def user_is_receiver?(user)
    sent_to == user.email
  end

  def aasm_state
    self[:aasm_state] || :empty
  end

  def update_pending_codes_status(status)
    user_sent_to = User.includes(:identities).where('identities.email = ? or users.email = ?', sent_to, sent_to).references(:identities).uniq.first
    if user_sent_to
      user_sent_to.assign_attributes(pending_codes: status)
      user_sent_to.save if user_sent_to.changed?
    end
  end

  def self.generate_code
    "#{Rails.application.config.bitshares.faucet_refcode_prefix}-#{SecureRandom.urlsafe_base64(8).upcase}"
  end

  def asset_amount
    self.amount / asset.precision
  end

  def mutate_expires_at(expires_at)
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

end
