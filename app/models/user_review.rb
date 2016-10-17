# == Schema Information
#
# Table name: user_reviews
#
#  id            :integer          not null, primary key
#  body          :text
#  price         :integer
#  user_photo_id :integer
#  tripnote_id   :integer
#  created_at    :datetime
#  updated_at    :datetime
#  user_id       :integer
#  tripnote_date :datetime
#

class UserReview < ActiveRecord::Base
  belongs_to :user
  belongs_to :tripnote
  has_many :user_photos

  def self.create_with_photo(user, tripnote, photo, body: nil)
    review = self.new(
      tripnote: tripnote,
      body: body,
      tripnote_date: photo.image_date,
      user: user
      )
    if review.save
      return review
    else
      loger.error "#{self.class.to_s}##{__method__.to_s}: #{review.errors.inspect}}"
      raise "ERROR: " + review.errors
    end
  end
end
