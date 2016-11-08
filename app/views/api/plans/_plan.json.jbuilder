json.extract! plan, :id, :user_id, :title, :description, :date_from, :date_to, :main_cc, :main_state_id, :published_at, :public_link_url
json.created_at plan.formatted_created_at
json.updated_at plan.formatted_updated_at
json.daily_plans plan.plan_dates.each do |plan_date|
  json.partial! "api/plans/daily_plan", date: plan_date, plan_items: plan.plan_items.merge(PlanItemMapping.daily(plan_date))
end
