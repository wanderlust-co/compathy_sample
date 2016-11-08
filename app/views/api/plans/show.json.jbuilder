json.response_status 1200
json.response_message "ok"
json.plan do
  json.partial! "api/plans/plan", plan: @plan
end

