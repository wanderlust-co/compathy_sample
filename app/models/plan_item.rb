class PlanItem < ActiveRecord::Base
  belongs_to :user
  belongs_to :plan, touch: true
  belongs_to :spot
end
