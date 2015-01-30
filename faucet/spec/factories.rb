FactoryGirl.define do
  factory :bts_account do
    name 'account'
    key '123'
  end

  factory :user do
    name 'User'
    email 'test@email.com'
    password '123456'
  end

end
