class ProviderCategory < ActiveRecord::Base
  has_one :category_map
  has_one :category, through: :category_map
end