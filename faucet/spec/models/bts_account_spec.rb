require 'rails_helper'

describe BtsAccount do
  describe "#filter" do
    it "should apply date scope if provided" do
      bts_account = create :bts_account, name: 'todayaccount', key: '234'
      bts_account_old = create :bts_account, created_at: Date.today - 1.day

      expect(BtsAccount.filter('Today')).to include(bts_account)
      expect(BtsAccount.filter('Today')).not_to include(bts_account_old)
    end
  end

end
