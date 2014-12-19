class BtsAccount < ActiveRecord::Base
  belongs_to :user
  before_create :generate_ogid

  def generate_ogid
    self.ogid = SecureRandom.urlsafe_base64(10)
  end
end