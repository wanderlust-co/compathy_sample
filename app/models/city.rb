class City < ActiveRecord::Base
  include CyUrlEncoder; extend CyUrlEncoder

  belongs_to :country, foreign_key: 'cc', primary_key: 'cc'
  belongs_to :state

  has_many :spots

  validates_presence_of :cc, :url_name

  # TODO: not implemented
  def trans_name( locale = nil )
    self.name
  end

  def self.find_or_create_by_name( cc, city_name, lat = nil, lng = nil )
    if city = self.where( cc: cc, url_name: cy_url_encode( city_name ) ).first
      if lat && lng && (!city.lat || !city.lng)
        city.update_attributes( lat: lat, lng: lng )
      end
      return city
    else
      city = self.new( cc: cc,
                       name: city_name,
                       lat: lat,
                       lng: lng,
                       url_name: cy_url_encode( city_name ) )
      if city.save
        return city
      end
    end
    nil
  end
end

