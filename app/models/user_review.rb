class UserReview < ActiveRecord::Base
  belongs_to :tripnote
  belongs_to :user_photo
end
