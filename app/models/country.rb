class Country < ActiveRecord::Base
  belongs_to :continent, foreign_key: 'continent_code', primary_key: 'continent_code'

  has_many :states, foreign_key: 'cc', primary_key: 'cc'
  has_many :cities, foreign_key: 'cc', primary_key: 'cc'

  has_many :country_translations, foreign_key: 'cc', primary_key: 'cc'

  def trans_name(locale = nil)
    retuen self.name if locale.nil? or locale.to_s == 'en'

    if self.country_translations.size > 0
      return self.country_translations.first.name
    end

    if ct = CountryTranslation.where(local: local.to_s, cc: self.cc).first
      return ct.name
    end

    self.name
  end
end
