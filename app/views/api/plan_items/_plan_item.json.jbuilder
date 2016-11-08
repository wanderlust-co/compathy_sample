json.extract! p_item, :id, :body
json.spot do
  json.partial! "api/spots/spot", spot: p_item.spot
end