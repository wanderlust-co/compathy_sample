tn = review.tripnote

json.extract!                  review, :id, :body, :rate, :cost, :tripnote_total_order
json.thumbnail_url             review.image_url( :thumb )
json.tripnote_date             review.tripnote_date ? review.tripnote_date.utc : nil
json.tripnote_title            tn.title
json.tripnote_link_url         tn.link_url
json.tripnote_formatted_date   review.tripnote_date ? review.tripnote_date.strftime("%Y/%m/%d") : nil

# json.user do
#   json.extract! review.user, :id, :name, :link_url, :thumbnail_url
# end

json.photos do
  json.array! review.user_photos.each do |photo|
    json.extract!  photo, :id, :image_lat, :image_lng
    json.thumbnailUrl     photo.image.url(:thumb)
    json.mediumUrl        photo.image.url(:medium)
  end
end

json.spot do
  json.extract! review.spot, :id, :lat, :lng, :url_name
  json.name     review.spot.trans_name(I18n.locale)
  json.fsqSpotId        review.spot.provider_spot_id
  json.linkUrl          review.spot.abs_url_name

  if review.spot.country
    json.country do
      json.extract!     review.spot.country, :url_name, :link_url
      json.name         review.spot.country.trans_name(I18n.locale)
    end
  end

  if review.spot.state
    json.state do
      json.extract!     review.spot.state, :id, :link_url
      json.name         review.spot.state.trans_name( I18n.locale )
    end
  end

  json.city             review.spot.city.name if review.spot.city
  json.bookmarkId       review.spot.user_bookmark_id(current_user.id) if current_user
  json.category         review.spot.category.capitalize if review.spot.category
  json.route            review.spot_route
end if review.spot

# json.liked_users   review.liked_users.each do |user|
#   json.extract!    user, :id, :name, :username, :link_url, :thumbnail_url
# end

# json.comments do
#   json.array! review.comments.each do |comment|
#     json.extract! comment, :id, :body
#     json.timestamp            comment.created_at
#     json.user do
#       json.extract! comment.user, :id, :name, :username, :link_url, :thumbnail_url
#     end
#   end
# end

