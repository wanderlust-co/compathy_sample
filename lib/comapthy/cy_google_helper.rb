module CyGoogleHelper
  class CyGoogleClient
    include CyHttpHelper;     extend CyHttpHelper

    def geocode( lat, lng, lang: "en" )
      result = nil
      spot_info = cy_get_http_response("http://maps.googleapis.com/maps/api/geocode/json?latlng=#{lat},#{lng}&language=#{lang}&sensor=false", false)
      if spot_info.code == "200" and spot_info.body
        result = JSON.parse( spot_info.body )
      end
      result
    end
  end

  def google_client
    CyGoogleClient.new
  end
end

