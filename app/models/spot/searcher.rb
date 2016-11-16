module Spot::Searcher
  extend ActiveSupport::Concern

  included do
    # NOTE: this calculation is based on just some sampling data.
    #       it should be refined with some consistent data.
    def self.expand_sw_ne_for_fsq(zoom:, sw:, ne:)
      base_zoom = 9
      zoom = zoom.to_i

      sw_lat = sw[:latitude]  || sw["latitude"]
      sw_lng = sw[:longitude] || sw["longitude"]
      ne_lat = ne[:latitude]  || ne["latitude"]
      ne_lng = ne[:longitude] || ne["longitude"]

      result = {
        sw: { latitude: sw_lat.to_f, longitude: sw_lng.to_f },
        ne: { latitude: ne_lat.to_f, longitude: ne_lng.to_f }
      }

      if zoom <= base_zoom
        return result
      end

      diff_zoom = zoom - base_zoom

      base_number = 0.25 # 0.25, 0.125, 0.0625, ...

      diff_zoom.times do
        result[:sw][:latitude]  = result[:sw][:latitude]  - base_number
        result[:sw][:longitude] = result[:sw][:longitude] - base_number - 0.1
        result[:ne][:latitude]  = result[:ne][:latitude]  + base_number
        result[:ne][:longitude] = result[:ne][:longitude] + base_number + 0.1
        base_number *= 0.5
      end

      if result[:sw][:latitude] > 90
        diff = result[:sw][:latitude] - 90
        result[:sw][:latitude] = 90 - diff
      end

      if result[:sw][:longitude] < -180
        diff = result[:sw][:longitude] + 180
        result[:sw][:longitude] = 180 + diff
      end

      if result[:ne][:latitude] > 90
        diff = result[:ne][:latitude] - 90
        result[:ne][:latitude] = -90 + diff
      end

      if result[:ne][:longitude] > 180
        diff = result[:ne][:longitude] - 180
        result[:ne][:longitude] = -180 + diff
      end

      return result
    end

    def self.need_expand_search?(search_params)
      return (!search_params[:cc].present? \
              && !search_params[:areaId].present? \
              && search_params[:sw].present? \
              && search_params[:ne].present? \
              && search_params[:zoom].present? \
              && search_params[:searchText].present? \
              && !search_params[:cat0Ids].present? \
              && !search_params[:cat2Ids].present? \
              && (!search_params[:page].present? || search_params[:page].to_i == 1)
             )
    end

    def self.search_by_country(cc:, cat0_codes:, cat2_codes:)
      _spots = Spot.where(cc: cc)

      cat_t  = Category.arel_table

      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat0_code].in cat0_codes) if cat0_codes.present?
      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat2_code].in cat2_codes) if cat2_codes.present?

      return _spots
    end

    def self.search_by_area(area_id:, cat0_codes:, cat2_codes:)
      radius_km = 30

      area = CY_AREAS.find { |item| item[:id] == area_id.to_i }
      lat  = area[:lat].to_f
      lng  = area[:lng].to_f
      # NOTE: calculate expanded geographical coverage from the state
      _spots = Spot.range(*Spot.coordinate_ranges_from_radius(lat, lng, radius_km))

      cat_t  = Category.arel_table

      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat0_code].in cat0_codes) if cat0_codes.present?
      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat2_code].in cat2_codes) if cat2_codes.present?

      return _spots
    end

    def self.search_by_rectangle(sw:, ne:, search_text: nil, cat0_codes: nil, cat2_codes: nil)
      sw = sw.with_indifferent_access
      ne = ne.with_indifferent_access

      lat_range  = sw[:latitude]..ne[:latitude]
      lng_range  = sw[:longitude]..ne[:longitude]
      _spots     = Spot.range(lat_range, lng_range)

      cat_t  = Category.arel_table

      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat0_code].in cat0_codes) if cat0_codes.present?
      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat2_code].in cat2_codes) if cat2_codes.present?

      if search_text
        if I18n.locale != :en
          _spots = _spots.joins("LEFT JOIN spot_translations ON spot_translations.spot_id = spots.id")
                         .where("spots.name LIKE ? OR spot_translations.name LIKE ?", "%#{search_text}%", "%#{search_text}%")
        else
          _spots = _spots.where("spots.name LIKE ?", "%#{search_text}%")
        end
      end
      return _spots
    end

    def self.search_by_global(search_text:, cat0_codes: nil, cat2_codes: nil)
      if I18n.locale != :en
        _spots = Spot.joins("LEFT JOIN spot_translations ON spot_translations.spot_id = spots.id")
                       .where("spots.name LIKE ? OR spot_translations.name LIKE ?", "%#{search_text}%", "%#{search_text}%")
      else
        _spots = Spot.where("spots.name LIKE ?", "%#{search_text}%")
      end

      cat_t  = Category.arel_table

      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat0_code].in cat0_codes) if cat0_codes.present?
      _spots = _spots.includes(:categories).references(:categories).where(cat_t[:cat2_code].in cat2_codes) if cat2_codes.present?
      return _spots
    end
  end
end
