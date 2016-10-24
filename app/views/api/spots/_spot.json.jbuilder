json.cache! spot, expires_in: 10.hours do
  json.extract! spot, :id, :address, :url, :tel, :fsq_spot_id, :thumbnail_url, :abs_url_name, :is_hotel
  json.lat            spot.lat.to_f
  json.lng            spot.lng.to_f
  json.name           spot.trans_name(I18n.locale)
  json.original_name  spot.name
  json.category_name  spot.level0_category_name
  json.category_names spot.categories.map {|cat| cat.trans_name(I18n.locale)}.join(", ")
  json.episode_num    spot.published_episodes_count
  json.likes_num      spot.likes_count
  json.stars          spot.hotel_stars
  json.base_price     spot.hotel_base_price
  json.currency       spot.hotel_currency

  json.country do
    json.partial! "v3/countries/country", country: spot.country
  end

  json.state do
    json.partial! "v3/states/state", state: spot.state
  end if spot.state

  json.city spot.city.name if spot.city
end

if local_assigns[:my_bookmark_spots_hash].nil?
  # FIXME: Except v3/search(planning), is bookmarkId necessary from client side?
  # Have a risk of n+1 problem
  bookmark_id = spot.bookmarks.find_by(user: current_user).try(:id)
else
  bookmark_id = my_bookmark_spots_hash[spot.id]
end
json.bookmarkId bookmark_id
