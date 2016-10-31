# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_photo_with_all, class: UserPhoto do
    user
    image_file_name        "hoge.jpg"
    client_file_identifier "(null):assets-library://asset/asset.JPG?id=CEDCB331-B48B-45A4-B594-DF82A0F1A52B&ext=JPG"
    image_lat 10
    image_lng 100
    image_date "2013-11-11 00:00:00"
  end

  factory :user_photo_with_geo, class: UserPhoto do
    user
    image_file_name "hoge.jpg"
    image_lat 10
    image_lng 100
  end

  factory :user_photo_with_date, class: UserPhoto do
    user
    image_file_name "hoge.jpg"
    image_date "2013-11-11 00:00:00"
  end

  factory :user_photo_without_all, class: UserPhoto do
    user
    image_file_name "hoge.jpg"
  end

  factory :user_photo, class: UserPhoto do
    user
    image_file_name "hoge.jpg"
  end

  factory :user_photo_waiting_upload, class: UserPhoto do
    user
    client_file_identifier "hogehogehoge"
    image_file_name CY_WAITING_PHOTO_UPLOAD
  end
end

