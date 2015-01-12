class DvsAccount < ActiveRecord::Base
  belongs_to :user
  before_create :generate_ogid

  validates :name, presence: true, format: {
      with: /\A[a-z]+(?:[a-z0-9\-])*[a-z0-9]\z/,
      message: 'Only lowercase alphanumeric characters and dashes. Must start with a letter and cannot end with a dash.'
  }
  validates :key, presence: true

  def generate_ogid
    self.ogid = SecureRandom.urlsafe_base64(10)
  end
end
