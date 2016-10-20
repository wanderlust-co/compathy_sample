class Country < ActiveRecord::Base
  belongs_to :continent, foreign_key: 'continent_code', primary_key: 'continent_code'

  has_many :states, foreign_key: 'cc', primary_key: 'cc'
  has_many :cities, foreign_key: 'cc', primary_key: 'cc'

  has_many :country_translations, foreign_key: 'cc', primary_key: 'cc'

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
end
