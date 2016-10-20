module CyFsqHelper
  def fsq_client
    Foursquare2::Client.new(client_id: ENV['FSQ_CLIENT_ID'], client_secret: ENV['FSQ_CLIENT_SECRET'], api_version: ENV['FSQ_API_VERSION'])
  end
end

