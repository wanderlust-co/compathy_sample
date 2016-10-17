json.extract!        tripnote, :title, :description
json.trionote_id      tripnote.id

# NOTE: max_page is excluded reivews count
if local_assigns[:max_page].nil?
  max_page = tripnote.user_reviews.count
end
json.episodesCount   max_page

json.owner do
  json.partial! "v3/users/other_user", other_user: tripnote.user
end

json.photo do
  json.partial! "v3/user_photos/user_photo", photo: tripnote.cover_photo
end if tripnote.cover_photo

if @is_from_ios
  json.tags     tripnote.tag_list.join(",")
  json.theme           tripnote.main_tag_name # TODO: backward compatibility for compathy_ios01 v1.1.0
else
  json.tags     tripnote.tag_list
end

if local_assigns[:country_code].nil?
  country_code = nil
end

json.countries tripnote.reorder_countries(country_code).uniq.take(3).each do |co|
  json.extract! co, :id, :cc
  json.name     co.trans_name(I18n.locale)
end

json.members tripnote.tripnote_friends.each do |friend|
  json.partial! "v3/tripnote_friends/friend", friend: friend
end

