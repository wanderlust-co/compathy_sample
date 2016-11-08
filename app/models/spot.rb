class Spot < ActiveRecord::Base
  require "#{Rails.root}/app/helpers/application_helper"
  include CyUrlEncoder;     extend CyUrlEncoder
  include CyValidateHelper; extend CyValidateHelper
  include CyFsqHelper;      extend CyFsqHelper
  include CyHttpHelper;     extend CyHttpHelper
  include CyGoogleHelper;   extend CyGoogleHelper

  # FIXME: work-around compathy admin error: Ruby2.2, Rails4.1, query_report version errors...
  include Spot::Searcher   if Rails.application.class.parent_name != "CompathyAdmin"
  include Spot::FsqHandler if Rails.application.class.parent_name != "CompathyAdmin"

  belongs_to :country, foreign_key: 'cc', primary_key: 'cc'
  belongs_to :city
  belongs_to :state
  belongs_to :user

  has_many :spot_categories, dependent: :destroy
  has_many :spot_translations, dependent: :destroy
  has_many :categories, through: :spot_categories
  has_many :tripnote_spot
  has_many :comments, through: :user_reviews
  has_many :user_photos
  has_many :bookmarks, -> { where( bk_type: CY_BK_TYPE_SPOT ) }, foreign_key: "bk_id"
  has_many :provider_hotels

  validates :name, presence: true
  validates :lat, presence: true
  validates :lng, presence: true
  validates :cc, presence: true
  validates :provider, presence: true
  validates :url_name, presence: true
  validates :abs_url_name, presence: true

  scope :has_reviews,             -> { where( "published_episodes_count > 0" ) }
  scope :order_by_reviews_count,  -> { order( "published_episodes_count DESC" ) }
  scope :order_by_reviews_length, -> { order( "CHAR_LENGTH( user_reviews.body ) DESC" ).references(:user_reviews) }
  scope :range,                   -> (lat_range, lng_range) { where(lat: lat_range, lng: lng_range) }
  scope :is_hotel,                -> { where( "is_hotel = 1" ) }

  @@delay_thumb_load = false
  @@is_loading_thumb = false

  def link_url ; self.abs_url_name ; end

  def fsq_spot_id
    if self.provider == "foursquare"
      self.provider_spot_id
    end
  end

  def self.find_or_create_by_fsq_spot_id( _fsq_spot_id )
    if spot = Spot.find_by(provider: 'foursquare', provider_spot_id: _fsq_spot_id)
      return spot
    else
      return self.create_from_fsq_spot_id( _fsq_spot_id )
    end
  end

  def self.create_from_fsq_spot_id( _fsq_spot_id )
    fsq_venue_result = fsq_client.venue( _fsq_spot_id )
    return self.create_from_fsq_venue(fsq_venue_result)
  end

  def self.create_from_fsq_venue(fsq_venue_result)
    if fsq_venue_result.location
      if cc = fsq_venue_result.location.cc
        # NOTE: sometime cc is not correct just as: https://developer.foursquare.com/docs/explore#req=venues/4b610a5df964a52069072ae3
        country = Country.find_by( cc: cc )
      end

      unless country
        state, city = Spot.get_state_city_from_google( fsq_venue_result.location.lat, fsq_venue_result.location.lng, nil )
        cc = state.cc if state
        cc = city.cc  if city
        country = Country.find_by( cc: cc ) if cc
      end
    end

    return nil unless country
    abs_url_name = "/countries/" + country.url_name + "/spots/" + cy_url_encode( fsq_venue_result.name )

    spot = Spot.new(
      name: fsq_venue_result.name,
      address: fsq_venue_result.location.address,
      tel:  fsq_venue_result.contact.formattedPhone,
      lat:  fsq_venue_result.location.lat,
      lng:  fsq_venue_result.location.lng,
      url:  fsq_venue_result.url,
      cc:   cc,
      provider: 'foursquare',
      provider_url: fsq_venue_result.canonicalUrl,
      provider_spot_id: fsq_venue_result.id,
      url_name: cy_url_encode( fsq_venue_result.name ),
      abs_url_name: abs_url_name,
      provider_rating: fsq_venue_result.rating
    )

    if spot.save
      spot.update_spot_city_state(state, city)
      is_hotel = false
      if fsq_venue_result.categories
        categories = fsq_venue_result.categories.map do |category|
          if pc = ProviderCategory.find_by( provider_category_id: category.id )
            # binding.pry
            if pc.category.present? && pc.category.cat0_code == CY_CAT0_IDS[:hotels][0]
              is_hotel = true
            end
            pc.category
          end
        end
        categories.delete( nil )

        begin
          spot.is_hotel = is_hotel
          spot.categories = categories if categories
          spot.save
        rescue ActiveRecord::RecordInvalid => ex
          logger.warn ex.message
        end
      end

      return spot
    else
      raise spot.errors
    end
    false
  end

  def category
    Category.select(:url_name).find(self.categories.first.cat0_code).url_name if self.categories.first
  end

  def trans_name( locale=nil )
    return self.name if locale.nil? or locale.to_s == 'en'

    if st = self.spot_translations.find_by( locale: locale.to_s )
      return st.name
    end
    self.name
  end

  def user_bookmark_id(user_id)
    bookmark = Bookmark.select( :id ).find_by( bk_type: CY_BK_TYPE_SPOT, bk_id: self.id, user_id: user_id )
    bookmark ? bookmark.id : nil
  end

  def update_spot_city_state(state=nil, city=nil)
    unless state && city
      state, city = Spot.get_state_city_from_google( self.lat, self.lng, self.cc )
    end
    self.update_attributes( state_id: state ? state.id : nil, city_id: city ? city.id : nil )
  end

  def main_photo
    if ep = main_episode
      if photos = ep.photos
        return photos.first
      end
    end
    nil
  end

  def self.set_delay_thumb_load(delay = true)
    @@delay_thumb_load = delay
  end

  def main_episode
    episodes.order("likes_count DESC").first
  end

  def thumbnail_url(size = :medium)
    if photo = self.main_photo
      return photo.image.url( size )
    end
    return get_provider_photo_url
  end

  def level0_category_name
    # NOTE: we take first category so far
    if cat = self.categories.first
      case cat.cat0_code
      when *CY_CAT0_IDS[:hotels]
        "hotels"
      when *CY_CAT0_IDS[:restaurants]
        "restaurants"
      when *CY_CAT0_IDS[:sites]
        "sites"
      end
    end
  end

  def main_category_name
    if cat = self.categories.first
      case cat.cat0_code
      when *CY_CAT0_IDS[:hotels]
        "泊まる"
      when *CY_CAT0_IDS[:restaurants]
        "食べる"
      when *CY_CAT0_IDS[:sites]
        "楽しむ"
      else
        ""
      end
    end
  end

  EARTH_RADIUS = 6378.137
  def self.coordinate_ranges_from_radius(lat, lng, radius_km = 50)
    lat_range_angle  = radius_km * 360 / (2 * Math::PI * EARTH_RADIUS)
    lng_angle_per_km = 360 / (2 * Math::PI * (EARTH_RADIUS * Math.cos(lat * Math::PI / 180).abs))
    lng_range_angle  = radius_km * lng_angle_per_km
    lat_range        = (lat - lat_range_angle)..(lat + lat_range_angle)
    lng_range        = (lng - lng_range_angle)..(lng + lng_range_angle)
    return lat_range, lng_range
  end

  private
  def self.get_state_city_from_google( lat, lng, cc )
    state = nil
    city  = nil
    begin
      # try Google API Reverse Geocoding
      location_info = google_client.geocode( lat, lng )

      if location_info.present? && location_info["results"].present?
        results = location_info["results"]
        # sometime, the first element contains administrative_area_level_1. Eg: http://maps.googleapis.com/maps/api/geocode/json?latlng=43.2386,76.9456&language=ja&sensor=false
        # and it may have only 1 element, then no city state location. Eg: http://maps.googleapis.com/maps/api/geocode/json?latlng=34.0716,-118.442&language=ja&sensor=false
        area_level_1 = {}
        area_level_2 = {}
        locality = {}
        country = {}
        results[0]["address_components"].each do |component|
          area_level_1[:name] = component['long_name'] if component['types'].include? 'administrative_area_level_1'
          area_level_2[:name] = component['long_name'] if component['types'].include? 'administrative_area_level_2'
          locality[:name] = component['long_name'] if component['types'].include? 'locality'
          country[:cc] = component['short_name'] if component['types'].include? 'country'
        end

        results.each do |result|
          if result['address_components'].length > 0 && name = result['address_components'][0]['long_name']
            if result['geometry'] && location = result['geometry']['location']
              if result['types'].include?( 'administrative_area_level_1' ) || ( area_level_1[:name] && !area_level_1[:lat] && area_level_1[:name] == name )
                area_level_1[:name] = name if !area_level_1[:name]
                area_level_1[:lat] = location['lat']
                area_level_1[:lng] = location['lng']
              end
              if result['types'].include?( 'administrative_area_level_2' ) || ( area_level_2[:name] && !area_level_2[:lat] && area_level_2[:name] == name )
                area_level_2[:name] = name if !area_level_2[:name]
                area_level_2[:lat] = location['lat']
                area_level_2[:lng] = location['lng']
              end
              if result['types'].include?( 'locality' ) || ( locality[:name] && !locality[:lat] && locality[:name] == name )
                locality[:name] = name if !locality[:name]
                locality[:lat] = location['lat']
                locality[:lng] = location['lng']
              end
            end

            if result['types'].include?( 'country' )
              country[:cc] = result['address_components'][0]['short_name']
            end
          end
        end

        logger.info "area_level_1: #{area_level_1} area_level_2 #{area_level_2} locality #{locality}"

        if country[:cc] or cc
          if area_level_1[:name]
            state = State.unscoped.find_or_create_by_name( country[:cc] || cc, area_level_1[:name], area_level_1[:lat], area_level_1[:lng], 'administrative_area_level_1' )
          # if no administrative_area_level_1, use administrative_area_level_2 instead. Taiwan case
          elsif area_level_2[:name]
            state = State.unscoped.find_or_create_by_name( country[:cc] || cc, area_level_2[:name], area_level_2[:lat], area_level_2[:lng], 'administrative_area_level_2' )
          # if no admin level 1 & 2, use locality instead. Seoul, Korea case. Ignore Singapore & Hong Kong
          elsif locality[:name]
            if co = Country.find_by( cc: country[:cc] || cc )
              if locality[:name] != co.name
                state = State.unscoped.find_or_create_by_name( country[:cc] || cc, locality[:name], locality[:lat], locality[:lng], 'locality' )
              end
            end
          end
          # NOTE use linked state if state is already merged
          if linked_state = state.try(:linked_state)
            state = State.find linked_state.linked_id
          end

          city = City.find_or_create_by_name( country[:cc] || cc, locality[:name], locality[:lat], locality[:lng] ) if locality[:name]
        end
      end

      return state, city
    rescue => ex
      logger.error ex.message
      raise ex.message
    end
  end
end
