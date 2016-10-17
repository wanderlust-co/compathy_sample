json.extract! review, :id, :body

json.photos  review.user_photos.each do |photo|
  json.partial! "user_photos/user_photo", photo: photo
end