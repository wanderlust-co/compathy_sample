class CategoryTranslation < ActiveRecord::Base
  belongs_to :category, touch: true

  validates_uniqueness_of :name, scope: [:category_id, :locale]
end
