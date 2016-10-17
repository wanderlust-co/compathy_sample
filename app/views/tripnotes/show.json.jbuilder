json.response_status  1200 # TODO: @res_status
json.response_message "response message"  # TODO: @res_message
json.tripnote do
  json.partial! "/tripnotes/tripnote", tripnote: @tripnote, reviews: @reviews
end