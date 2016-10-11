class UserReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :tripnote
  has_many :user_photos
  accepts_nested_attributes_for :user_photos
end
