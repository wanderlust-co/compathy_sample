json.extract!        tripnote, :title, :description
# json.date_from       tripnote.formatted_date_from
# json.date_to         tripnote.formatted_date_to
# json.likes_count     tripnote.total_likes_count
# json.updated_at      tripnote.formatted_updated_at
# json.published_at    tripnote.formatted_published_at
# json.republished_at  tripnote.formatted_republished_at
# json.countries_count tripnote.countries.uniq.count
json.tripnote_id      tripnote.id

# NOTE: max_page is excluded reivews count
# if local_assigns[:max_page].nil?
#   max_page = tripnote.reviews.count
# end
# json.episodesCount   max_page

# json.owner do
#   json.partial! "/users/other_user", other_user: tripnote.user
# end

json.photo do
  json.partial! "/user_photos/user_photo", photo: tripnote.cover_photo
end if tripnote.cover_photo

# if @is_from_ios
#   json.tags     tripnote.tag_list.join(",")
#   json.theme           tripnote.main_tag_name # TODO: backward compatibility for compathy_ios01 v1.1.0
# else
#   json.tags     tripnote.tag_list
# end

# if local_assigns[:country_code].nil?
#   country_code = nil
# end

# json.countries tripnote.reorder_countries(country_code).uniq.take(3).each do |co|
#   json.extract! co, :id, :cc
#   json.name     co.trans_name(I18n.locale)
# end

# json.members tripnote.tripnote_friends.each do |friend|
#   json.partial! "v3/tripnote_friends/friend", friend: friend
# end