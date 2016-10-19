json.extract!      photo, :id, :user_review_id, :image_lat, :image_lng
json.image_url photo.image.url(:thumb)