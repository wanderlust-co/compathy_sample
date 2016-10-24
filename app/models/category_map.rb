class CategoryMap < ActiveRecord::Base
  belongs_to :category
  belongs_to :provider_category

  validates_uniqueness_of :category_id, scope: [:provider_category_id]
end