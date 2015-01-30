class BtsAccount < ActiveRecord::Base
  DATE_SCOPES = ['Today', 'Yesterday', 'This week', 'Last week', 'This month', 'Last month', 'All']

  belongs_to :user

  validates :name, presence: true, format: {
      with: /\A[a-z]+(?:[a-z0-9\-])*[a-z0-9]\z/,
      message: 'Only lowercase alphanumeric characters and dashes. Must start with a letter and cannot end with a dash.'
  }
  validates :key, presence: true

  before_create :generate_ogid

  scope :grouped_by_referrers, -> { select([:referrer, 'count(*) as count']).group(:referrer).order('count desc') }

  def generate_ogid
    self.ogid = SecureRandom.urlsafe_base64(10)
  end

  def self.filter(scope_name)
    return self if scope_name == 'All' || !scope_name.in?(DATE_SCOPES)

    date = case scope_name
             when 'Today'
               Date.today.beginning_of_day..Date.today.end_of_day
             when 'Yesterday'
               (Date.today - 1.day).beginning_of_day..(Date.today - 1.day).end_of_day
             when 'This week'
               Date.today.at_beginning_of_week..Date.today
             when 'Last week'
               1.week.ago.at_beginning_of_week..1.week.ago.at_end_of_week
             when 'This month'
               Date.today.at_beginning_of_month..Date.today
             when 'Last month'
               1.month.ago.at_beginning_of_month..1.month.ago.at_end_of_month
           end
    self.where(created_at: date)
  end

end
