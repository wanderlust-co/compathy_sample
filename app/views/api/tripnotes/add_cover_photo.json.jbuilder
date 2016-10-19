json.response_status  1200 # TODO: @res_status
json.response_message "response message"  # TODO: @res_message
json.photo do
  json.partial! "/user_photos/user_photo", photo: @photo
end

