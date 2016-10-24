class Country < ActiveRecord::Base
  belongs_to :continent, foreign_key: 'continent_code', primary_key: 'continent_code'

  has_many :spots, foreign_key: 'cc', primary_key: 'cc'
  has_many :cities, foreign_key: 'cc', primary_key: 'cc'
  has_many :states, foreign_key: 'cc', primary_key: 'cc'
  has_many :country_translations, foreign_key: 'cc', primary_key: 'cc'

  validates_uniqueness_of :cc

  scope :has_tripnotes,            -> { where( "published_tripnotes_count > 0" ) }
  scope :order_by_tripnotes_count, -> { order( "published_tripnotes_count DESC" ) }

  def self.select_options
    Country.all.map {|co| [ co.trans_name(I18n.locale), co.cc ] }
  end

  def link_url ; "/countries/" + self.url_name ; end

  def trans_name( locale=nil )
    return self.name if locale.nil? or locale.to_s == 'en'

    # FIXME: seems not right way for N+1 problem
    if self.country_translations.size > 0
      return self.country_translations.first.name
    end

    if ct = CountryTranslation.where( locale: locale.to_s, cc: self.cc ).first
      return ct.name
    end
    self.name
  end

  def tripnotes( openness = CY_OPENNESS[:full] )
    tripnote_ids = UserReview.select( :tripnote_id ).
      joins( :spot, :tripnote).
      where( "user_reviews.tripnote_id IS NOT NULL
            AND tripnotes.openness = ?
            AND spots.cc = ?", openness, self.cc ).uniq.
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
    self.update( published_tripnotes_count: self.tripnotes( CY_OPENNESS[:full] ).size )
  end

  def cat0_codes
    Rails.cache.fetch("#{cache_key}/cat0_codes", expires_in: 1.day) do
      result = Country.find_by_sql("
        SELECT sp.id,sp.name,sp.cc,sp.state_id, cat.id,cat.name,cat.cat0_code FROM spot_categories sc
          INNER JOIN spots sp ON sc.spot_id = sp.id
          INNER JOIN categories cat ON sc.category_id = cat.id
          WHERE sp.cc = '#{self.cc}'
          GROUP BY cat0_code;")
      result.map {|r| r.cat0_code}
    end
  end
end

