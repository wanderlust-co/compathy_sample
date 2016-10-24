class State < ActiveRecord::Base
  include CyUrlEncoder; extend CyUrlEncoder

  belongs_to :country, foreign_key: 'cc', primary_key: 'cc'

  has_one  :linked_state

  has_many :cities
  has_many :spots, dependent: :destroy
  has_many :state_translations, dependent: :destroy

  validates_presence_of :cc, :name, :url_name

  # NOTE: migrate state_id on spots with maintenance LinkedState(merge state), so that linked_state should be always excluded
  default_scope -> { where.not(id: LinkedState.select(:state_id)) }
  scope :has_tripnotes,            -> { where( "published_tripnotes_count > 0" ) }
  scope :order_by_tripnotes_count, -> { order( "published_tripnotes_count DESC" ) }

  def self.find_or_create_by_name( cc, state_name, lat = nil, lng = nil, gg_type = 'administrative_area_level_1' )
    if state = self.where( cc: cc, url_name: cy_url_encode( state_name ) ).first
      if lat && lng && (!state.lat || !state.lng)
        state.update_attributes( lat: lat, lng: lng )
      end
      return state
    else
      state = self.new( cc: cc,
                        name: state_name,
                        lat: lat,
                        lng: lng,
                        gg_type: gg_type,
                        url_name: cy_url_encode( state_name ) )
      if state.save
        return state
      end
    end
    nil
  end

  def link_url ; "/countries/" + self.country.url_name + "/states/" + self.url_name ; end

  def trans_name( locale=nil )
    return self.name if locale.nil? or locale.to_s == 'en'
    if st = self.state_translations.where( locale: locale.to_s ).take
      return st.name
    end
    self.name
  end

  def image_url( size = :medium )
    return thumbnail_url if self.thumbnail_url

    # FIXME: update to thumbnail_url field to reduce extra query
    if user_photo = UserPhoto.top_likes.where("spots.state_id = ?", self.id ).first
      return user_photo.image.url( size )
    else
      NO_IMAGE_URL
    end
  end

  def user_photos
    UserPhoto.joins( :tripnote, :user_review, [spot: :state] )
             .where( "user_reviews.id IS NOT NULL
                      AND tripnotes.id IS NOT NULL AND tripnotes.openness > ?
                      AND spots.state_id = ?", CY_OPENNESS[:draft], self.id )
  end

  def tripnotes( openness = CY_OPENNESS[:full] )
    tripnote_ids = UserReview.select( :tripnote_id ).
      joins( :spot, :tripnote).
      where( "user_reviews.tripnote_id IS NOT NULL
            AND tripnotes.openness = ?
            AND spots.state_id = ?", openness, self.id ).uniq.
      collect { |ur| ur.tripnote_id }

    Tripnote.where( "tripnotes.id IN (?)", tripnote_ids )
  end
  alias_method :logbooks, :tripnotes

  def spots_by_cat0( cat0_ids )
    self.spots.has_reviews.joins( :categories ).where( "categories.cat0_code IN (?)", cat0_ids ).uniq
  end

  def tripnotes_by_tag( tag )
    tag.class == Tag ? tag_name = tag.name : tag_name = tag

    tripnotes    = self.tripnotes
    tripnote_ids = tripnotes.collect(&:id)
    Tripnote.tagged_with( tag_name ).where( "tripnotes.id IN (?)", tripnote_ids )
  end

  def update_published_tripnotes_count
    user_visible_count = self.tripnotes.joins(:tripnote_total_rank_histories).where(tripnote_total_rank_histories: {rank_date: 2.day.ago.strftime("%Y-%m-%d")}).size
    self.update( published_tripnotes_count: user_visible_count )
  end

  def cat0_codes
    Rails.cache.fetch("#{cache_key}/cat0_codes", expires_in: 1.day) do
      result = State.find_by_sql("
        SELECT sp.id,sp.name,sp.cc,sp.state_id, cat.id,cat.name,cat.cat0_code FROM spot_categories sc
          INNER JOIN spots sp ON sc.spot_id = sp.id
          INNER JOIN categories cat ON sc.category_id = cat.id
          WHERE sp.state_id = '#{self.id}'
          GROUP BY cat0_code;")
      result.map {|r| r.cat0_code}
    end
  end
end

