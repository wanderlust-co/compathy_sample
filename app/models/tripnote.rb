class Tripnote < ActiveRecord::Base
  belongs_to :user
  has_many :user_reviews
  accepts_nested_attributes_for :user_reviews
  belongs_to :user_photo
end
