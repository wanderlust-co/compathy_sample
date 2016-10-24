class SpotCategory < ActiveRecord::Base
  belongs_to :spot
  belongs_to :category

  validates :category, presence: true
  validates :spot, presence: true, uniqueness: { scope: :category_id }
end
