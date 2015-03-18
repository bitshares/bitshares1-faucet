FactoryGirl.define do
  factory :bts_account do
    name 'account'
    key '123'
  end

  factory :user do
    name 'User'
    email 'test@email.com'
    password '123456'

    trait :confirmed do
      confirmed_at Time.now
    end
  end

  factory :asset do
    precision 100
  end

  factory :referral_code do
    code '123-123123'
    amount 10
    asset_id { create(:asset).id }
    expires_at Time.now + 1.day

    trait :funded do
      aasm_state 'funded'
      funded_by 'some_guy'
    end
  end

end
