json.date date
json.plan_items plan_items.each do |p_item|
  json.partial! "api/plan_items/plan_item", p_item: p_item
end
