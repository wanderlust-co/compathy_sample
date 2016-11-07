class PlanItemMapping < ActiveRecord::Base
  belongs_to :plan, touch: true
  belongs_to :plan_item
end
