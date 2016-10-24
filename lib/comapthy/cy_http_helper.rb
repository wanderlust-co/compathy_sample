module CyHttpHelper
  def cy_get_http_response(url, use_ssl = false, read_timeout: 10)
    uri               = URI.parse(url)
    http              = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl      = use_ssl
    http.read_timeout = read_timeout
    request           = Net::HTTP::Get.new(uri.request_uri)
    response          = http.request(request)
  end
end
