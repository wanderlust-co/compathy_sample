# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :title do |n|
    "title#{n}"
  end

  sequence :favorites_count do |n|
    n*10
  end

  factory :tripnote do
    user
    title            { generate( :title ) }
    # date_from        "2014-02-01"
    # date_to          "2014-02-05"
    description      "tripnote desc"
    # edit_once        true
    openness         10
    favorites_count  { generate( :favorites_count ) }
    user_photo
    # published_at     Time.now
    # published_by_ua  "compathy01/1 (iPhone; iOS 7.1.2; Scale/2.00)"
  end
end

