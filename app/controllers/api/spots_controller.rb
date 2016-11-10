module Api
  class SpotsController < Api::ApplicationController
    include CyFsqHelper;      extend CyFsqHelper
    before_action :require_authentication, only: %w(create)

    def show_with_episodes
      page      = params[:page].presence || 1
      per       = params[:per].presence || 20
      @spot     = Spot.find(params[:id])
      @episodes = @spot.episodes.exc_rough.opened.order_by_likes_count.includes(:user, :user_photos).page(page).per(per)
    end

    def search
      is_global_search = params[:isGlobalSearch].present? ? params[:isGlobalSearch] == 'true' : false 
      if !(params[:cc] || params[:areaId] || (params[:sw] && params[:ne]) || is_global_search)
        raise "ERROR: You should provide at least one of the mandatory parameters (cc, areaId, or sw & ne) or do a global search"
      end

      order_by        = params[:orderBy].presence || CY_SPOT_ORDER_BY[:episodes]
      order_direction = params[:orderDirection].presence || CY_ORDER_BY_DIRECTIONS[:descending]
      excluded_ids    = params[:excludedIds].presence || []
      page = params[:page].presence || 1
      per  = params[:per].presence || 30
      expected_num = per.to_i
      radius_km = 30

      if params[:cc]
        @spots = Spot.search_by_country(
          cc: params[:cc],
          cat0_codes: params[:cat0Ids],
          cat2_codes: params[:cat2Ids],
        )
        apply_common_treating(order_by, order_direction, page, per, excluded_ids)
        return
      end

      if params[:areaId]
        @spots = Spot.search_by_area(
          area_id: params[:areaId],
          cat0_codes: params[:cat0Ids],
          cat2_codes: params[:cat2Ids],
        )
        apply_common_treating(order_by, order_direction, page, per, excluded_ids)

        if @spots.size < expected_num
          # NOTE: We have to turn the spot active records into an array to be able to "inject" our own Foursquare results
          @spots = @spots.to_a

          needed_spots = expected_num - @spots.size

          begin
            venues = Spot.search_fsq_venues(
              area_id: params[:areaId],
              level0_cats: params[:cat0Ids],
              level2_cats: params[:cat2Ids],
            )
          rescue => ex
            render_error(message: ex.message)
            return
          end

          if 0 < venues.size
            new_spots = Spot.create_spots_from_fsq(venues: venues, amount: needed_spots, include_minor_spot: true)

            if 0 < new_spots.size
              @spots = @spots + new_spots.order("spots.name").includes(:categories, :country, :state, :city).to_a
            end
          end
        end

        return
      end
    end

    def fsq_categories
      if params["cyNewSpotFilter"]
        categories = Category.find(CY_NEW_SPOT_FILTERED_CATEGORIES.keys)
      else
        categories = Category.where(level: 2).select(&:provider_category)
      end

      @categories = categories.map { |cat|
        {
          fsqCatId: cat.provider_category.provider_category_id,
          name: cat.trans_name(I18n.locale),
          group: Category.find(cat.cat1_code).trans_name(I18n.locale)
        }
      }.compact
    end

    def get_thumbs
      spot_ids = params[:spotIds].presence || []
      @thumbs = []
      if spot_ids.length > 0
        @thumbs = Spot.where(:id => spot_ids).map{ |spot|
          {
            id: spot.id,
            thumbnail_url: spot.provider_photo_url
          }
        }
      end
    end

    def get_fsq_pics
      fsqId = params[:fsqId].presence
      limit = params[:limit].presence || 4
      # NOTE: According to https://developer.foursquare.com/overview/venues#display
      # we have to limit the number of FSQ pictures we display to 4!
      limit = 4 if limit.to_i > 4
      @fsq_pics = []
      begin
        fsq_venue_result = fsq_client.venue(fsqId)
        if photos = fsq_venue_result.photos
          if photos.groups.present?
            if items = photos.groups[0].items
              @fsq_pics = items.take(limit.to_i).map{ |photo| photo.prefix + FSQ_DEFAULT_SIZE + photo.suffix }.compact
            end
          end
        end
      rescue => ex
        render_error(message: ex.message)
        return
      end
    end

    def create
      client = Foursquare2::Client.new(
        oauth_token: ENV["FSQ_ACCESS_TOKEN"],
        api_version: ENV["FSQ_API_VERSION"])

      new_venue_params = {
        name: params[:spot][:name],
        ll: [params[:spot][:lat], params[:spot][:lng]].join(","),
        primaryCategoryId: params[:spot][:fsqCatId]
      }
      begin
        venue = client.add_venue(new_venue_params)
      rescue => ex
        # FIXME: duplicate spot found, ignore it & post again
        if ex.try(:response) && ex.response.ignoreDuplicatesKey
          force_new_venue_params = new_venue_params.merge({
            ignoreDuplicates: true,
            ignoreDuplicatesKey: ex.response.ignoreDuplicatesKey
          })

          venue = client.add_venue(force_new_venue_params)
        else
          render_error(message: ex.message)
          return
        end
      end

      if @spot = Spot.create_from_fsq_venue(venue)
        render :show
      else
        render_error(message: @spot.errors.inspect)
      end
    end

    def bk_users
      @spot     = Spot.find(params[:id])
      @bk_users = @spot.bookmarked_users.order(created_at: :desc)
    end

    private
    def apply_common_treating(order_by, order_direction, page, per, excluded_ids)
      @spots = @spots.where.not(id: DUP_SPOT_IDS + excluded_ids)
      my_bookmark_spots = @spots.includes(:bookmarks).where("bookmarks.user_id = ?", current_user.id).references(:bookmarks)
      @my_bookmark_spots_hash = Hash[*my_bookmark_spots.pluck("spots.id", "bookmarks.id").flatten]

      unless CY_ORDER_BY_DIRECTIONS.key? order_direction
        order_direction = CY_ORDER_BY_DIRECTIONS[:descending]
      end
      @spots = @spots.joins("LEFT JOIN (select spots.id as spot_id, count(b.bk_id) as spot_likes from spots
            inner join bookmarks b on b.bk_id = spots.id
            group by spots.id) q on q.spot_id = spots.id").group("spots.id")
      case order_by
        when CY_SPOT_ORDER_BY[:episodes]
          @spots = @spots.order("published_episodes_count " + order_direction).order("spot_likes " + order_direction).order("spots.name")
        when CY_SPOT_ORDER_BY[:likes]
          @spots = @spots.order("spot_likes " + order_direction).order("published_episodes_count " + order_direction).order("spots.name")
        when CY_SPOT_ORDER_BY[:price]
          @spots = @spots.order("-hotel_base_price " + order_direction).order("published_episodes_count " + order_direction).order("spots.name")
      end
      @spots = @spots.page(page).per(per).includes(:categories, :country, :state, :city)
      @spots.set_delay_thumb_load()
      @spots = @spots.to_a
    end
  end
end