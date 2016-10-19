# NOTE: include user into cache-hash to avoid adding touch option onto has_many association (has heavy risk)
# NOTE: Use cache key for reviews.size, because it's safe with touching tripnote with 'belogngs_to association'
json.cache! [tripnote, @country_code, tripnote.user, reviews.size], expires_in: 10.hour do
  json.extract! tripnote, :id
  reviews_count = tripnote.user_reviews.size
  json.cover do
    json.partial! "/api/tripnotes/cover", tripnote: tripnote
  end

  json.reviews reviews.each do |review|
    json.partial! "/user_reviews/user_review", review: review
  end
end
