module Spot::FsqHandler
  extend ActiveSupport::Concern

  included do
    def self.is_rectangle_too_big?(sw:, ne:)
      sw = sw.with_indifferent_access
      ne = ne.with_indifferent_access
      ne_lat = ne[:latitude].to_f
      sw_lat = sw[:latitude].to_f
      ne_lng = ne[:longitude].to_f
      sw_lng = sw[:longitude].to_f

      ((ne_lat - sw_lat).abs + (ne_lng - sw_lng).abs) > 5
    end

    def self.search_fsq_venues(cc: nil, area_id: nil, sw: nil, ne: nil, search_radius: 50000, level0_cats: [], level2_cats: [], search_text: nil)
      search_limit = FSQ_SEARCH_LIMIT
      venues        = []
      categories    = []

      if level2_cats.present? && level2_cats.length > 0
        categories  = CY_CAT2S.select{ |lc2| level2_cats.index(lc2[:id].to_s).present? }.map {|lc2| lc2[:fsqIds] }
      elsif level0_cats.present? && level0_cats.length > 0
        categories  = CY_CAT0S.select{ |lc0| level0_cats.index(lc0[:id].to_s).present? }.map {|lc0| lc0[:fsqIds] }
      end

      fsq_query = {
        :limit      => search_limit,
        :categoryId => categories.join(","),
        :intent     => "checkin",
        :query      => search_text
      }

      if sw && ne
        sw = sw.with_indifferent_access
        ne = ne.with_indifferent_access
        ne_lat = ne[:latitude].to_f
        sw_lat = sw[:latitude].to_f
        ne_lng = ne[:longitude].to_f
        sw_lng = sw[:longitude].to_f

        if self.is_rectangle_too_big?(sw: sw, ne: ne)
          # We can't use the sw & ne area if it's too big. We have to convert it into lat & lng
          lat                 = (sw_lat + ne_lat) / 2
          lng                 = (sw_lng + ne_lng) / 2
          search_radius       = Spot.radius_from_coordinate_ranges(sw, ne)
          logger.info "- Quering FSQ venues for calculated lat: #{lat}, lng: #{lng}, radius(meters): #{search_radius}, and categories: #{categories.join(', ')}"
          fsq_query[:ll]      = "#{lat},#{lng}"
          fsq_query[:radius]  = search_radius

          # TODO: why this happen??
          if fsq_query[:ll] == "0.0,0.0"
            fsq_query[:ll]      = "1.0,1.0"
          end
        else
          logger.info "- Quering FSQ venues for the southwest (#{sw}) and north_east (#{ne}) area, with categories: #{categories.join(', ')}"
          fsq_query[:sw]      = "#{sw_lat},#{sw_lng}"
          fsq_query[:ne]      = "#{ne_lat},#{ne_lng}"
          fsq_query[:intent]  = "browse"
        end
      elsif area_id.present?
        area = CY_AREAS.find { |item| item[:id] == area_id.to_i }
        lat  = area[:lat].to_f
        lng  = area[:lng].to_f

        logger.info "- Quering FSQ venues for lat: #{lat}, lng: #{lng}, and categories: #{categories.join(', ')}"
        fsq_query[:ll]        = "#{lat},#{lng}"
        fsq_query[:radius]    = search_radius
      elsif cc
        # It turns out that we can actually use the country to find spots using the "near" parameter!
        logger.info "- Quering FSQ venues near country code #{cc}"
        fsq_query[:near]      = cc
        fsq_query[:intent]    = "browse"
      else
        # We use global intent
        fsq_query[:intent]  = "global"
        if search_text.blank?
          return []
        end
      end

      begin
        fsq_venue_result = fsq_client.search_venues(fsq_query)
        # TODO: for debug. it should be moved to the test code
        # raise Foursquare2::APIError.new(Hashie::Mash.new({code: 500, errorDetail: "hoge", errorType: "fuga"}), "fuga")
      rescue Foursquare2::APIError => ex
        raise ex.message
      end

      if fsq_venue_result.venues && fsq_venue_result.venues.length > 0
        venues = fsq_venue_result.venues
      end
      logger.info "- Found #{venues.length} match(es)"
      return venues
    end

    def self.create_spots_from_fsq(venues:, amount:, include_minor_spot:)
      return if amount < 1

      spots           = []
      spot_categories = []
      categories      = []
      existing_spots  = []

      if venues.length > 0
        existing_spots = Spot.where(:provider_spot_id => venues.map{ |venue| venue.id }).pluck(:provider_spot_id).uniq

        venues.each do |venue|
          break if amount < 1
          if venue && existing_spots.index(venue.id).nil?
            if !include_minor_spot && venue.stats && venue.stats.checkinsCount && venue.stats.checkinsCount < FSQ_MIN_CHECKINS_THRESHOLD
              logger.info "!! Ignoring venue without enough checkins (#{venue.stats.checkinsCount}): #{venue.name}"
              next
            end
            logger.info "-- Found venue: #{venue.name}"
            if venue.location
              if cc = venue.location.cc
                # NOTE: sometime cc is not correct just as: https://developer.foursquare.com/docs/explore#req=venues/4b610a5df964a52069072ae3
                country = Country.where(cc: cc).first
              end
              unless country
                state, city = Spot.get_state_city_from_google(venue.location.lat, venue.location.lng, nil)
                cc          = state.cc if state
                cc          = city.cc  if city
                country     = Country.where(cc: cc).first if cc
              end
            end
            return nil unless country
            abs_url_name = "/countries/" + country.url_name + "/spots/" + cy_url_encode(venue.name)
            spot = Spot.new(
              name:             venue.name,
              address:          venue.location.address,
              tel:              venue.contact.formattedPhone,
              lat:              venue.location.lat,
              lng:              venue.location.lng,
              url:              venue.url,
              cc:               cc,
              provider:         'foursquare',
              provider_url:     venue.canonicalUrl,
              provider_spot_id: venue.id,
              url_name:         cy_url_encode(venue.name),
              abs_url_name:     abs_url_name,
              provider_rating:  venue.rating
            )
            if venue.categories.present?
              # We get the default icon
              if icon = venue.categories[0].icon
                icon_path = icon[:prefix][icon[:prefix].index(FSQ_ICON_REPLACE_KEY) + FSQ_ICON_REPLACE_KEY.length, 10000] # Deliberately chosen huge value
                full_path = FSQ_ICON_PATH_PREFIX + FSQ_ICON_REPLACE_KEY + icon_path + FSQ_ICON_PATH_SUFFIX + icon[:suffix]
                spot.provider_photo_url = full_path
              end
              is_hotel = false
              categories = venue.categories.map do |category|
                if pc = ProviderCategory.where(provider_category_id: category.id).first
                  if pc.category.present? && pc.category.cat0_code == CY_CAT0_IDS[:hotels][0]
                    is_hotel = true
                  end
                  pc.category
                end
              end
              categories.delete(nil)
              if categories
                spot.is_hotel = is_hotel
                spot.categories = categories
                spot_categories << { spot_fsq_id: venue.id, categories: categories.map{ |cat| cat.id }}
              end
            end
            spots << spot
            existing_spots << spot.provider_spot_id
            amount -= 1
          end
        end

        # Bulk Insert...
        if spots.length < 1
          logger.info "!!! There are no spots to insert on the DB"
        end

        Spot.transaction do
          logger.info "!!! Bulk inserting: #{spots.length} spots"
          Spot.import spots, :validate => true
          logger.info "Processing the spot categories"
          created_spots = Spot.where(:provider_spot_id => spots.map{ |new_spot| new_spot.provider_spot_id }).uniq
          bulk_spot_categories = []
          created_spots.each do |new_spot|
            spot_cats = spot_categories.select{ |sc| sc[:spot_fsq_id] == new_spot.provider_spot_id }
            if spot_cats.length > 0
              spot_cat_temp = spot_cats[0]
              spot_cat_temp[:categories].each do |category|
                spot_cat = SpotCategory.new(
                  spot_id: new_spot.id,
                  category_id: category
                )
                bulk_spot_categories << spot_cat
              end
              spot_categories.delete(spot_cat_temp)
            end
            # NOTE: async here because its not used instantly at the plan edit page for now.
            new_spot.delay.update_spot_city_state(nil, nil)
          end
          logger.info "!!! Bulk inserting the corresponding categories (#{bulk_spot_categories.length} items)"
          SpotCategory.import bulk_spot_categories, :validate => true
          return created_spots
        end
      end
    end
  end
end
