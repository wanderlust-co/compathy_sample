json.countries do |json|
  json.array! @countries.each do |country|
    json.extract!   country, :cc, :link_url
    json.name country.trans_name( I18n.locale )
  end
end