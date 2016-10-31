# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :favorite do
    user
    tripnote
    fb_story_id "FB_STORY_ID"
  end
end
