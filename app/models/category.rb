class Category < ActiveRecord::Base
  has_many :spot_categories
  has_many :spots, through: :spot_categories
  has_many :category_translations

  has_one :category_map
  has_one :provider_category, through: :category_map

  def self.level0_cat_name( cat_url_name )
    case cat_url_name
    when "hotels"
      "泊まる"
    when "restaurants"
      "食べる"
    when "sites"
      "楽しむ"
    end
  end

  def self.promo_word( cat_url_name )
    # NOTE: for "%{promotion_word}の旅行記をランキング別で…"
    case cat_url_name
    when "hotels"
      "ホテルについて"
    when "restaurants"
      "食べ物について"
    when "sites"
      "観光地について"
    end
  end

  def trans_name( locale=nil )
    return self.name if locale.nil? or locale.to_s == 'en'

    if ct = CategoryTranslation.where( category_id: self.id, locale: locale.to_s ).take
      return ct.name
    end
    self.name
  end

  def sub_ids( cat_id, cat_level )
    case cat_level
    when 0
      Category.where( cat0_code: cat_id).collect &:id
    when 1
      Category.where( cat1_code: cat_id).collect &:id
    when 2
      Category.where( cat2_code: cat_id).collect &:id
    end
  end

  def parent
    case self.level
    when 0
      nil
    when 1
      Category.where( level: 0, cat0_code: self.cat0_code ).first
    when 2
      Category.where( level: 1, cat1_code: self.cat1_code ).first
    when 3
      Category.where( level: 2, cat2_code: self.cat2_code ).first
    end
  end
end
