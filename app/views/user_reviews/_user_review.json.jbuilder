json.extract! review, :id, :body
json.tripnote_id     review.tripnote_id

json.photos  review.user_photos.each do |photo|
  json.partial! "user_photos/user_photo", photo: photo
end