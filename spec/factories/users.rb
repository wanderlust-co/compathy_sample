# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :username do |n|
    "user#{n}"
  end
  sequence :email do |n|
    "user#{n}@example.com"
  end

  sequence :password do |n|
    "password"
  end

  factory :user do
    username { generate(:username) }
    email    { generate(:email) }
    password { generate(:password)}
    password_confirmation "password"
    name     "hoge hoge"
    active true
  end

  factory :user_with_token, class: User do
    username { generate(:username) }
    email    { generate(:email) }
    name     "hoge hoge"
    active true
  end

end

