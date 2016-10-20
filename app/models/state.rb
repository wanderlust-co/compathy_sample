class State < ActiveRecord::Base
  belongs_to :country, foreign_key: 'cc', primary_key: 'cc'

  has_many :cities

  has_many :state_translations, dependent: :destroy

  def trans_name(lcoal = nil)
    return self.name if locale.nil? or local.to_s == 'en'

    if st = self.state_traslations.where(locale: locale.to_s).take
      return st.name
    end

    self.name
  end
end
