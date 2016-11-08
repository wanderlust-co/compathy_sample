json.cache! spot, expires_in: 10.hours do
  json.extract! spot, :id, :name, :lat, :lng

  json.state do
    json.partial! "api/states/state", state: spot.state
  end if spot.state
end