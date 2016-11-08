class PlanItemMapping < ActiveRecord::Base
  belongs_to :plan, touch: true
  belongs_to :plan_item

  scope :daily, ->(date) { where(date: date).order(:order) }
end
