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
  include CyFsqHelper; extend CyFsqHelper

  belongs_to :user
  belongs_to :tripnote
  belongs_to :spot
  has_many :user_photos
  belongs_to :spot_route
  has_many :comments, -> {where(cm_type: CY_CM_TYPE_REVIEW)}, foreign_key: "cm_id", dependent: :destroy
  has_many :likes, -> { where( like_type: CY_LIKE_TYPE_REVIEW ) }, foreign_key: "like_id", dependent: :destroy

  def self.create_with_photo(user, tripnote, photo, body: nil)
    review = self.new(
      tripnote: tripnote,
      body: body,
      tripnote_date: photo.image_date,
      user: user
      )

    if photo.image_lat && photo.image_lng
      begin
        fsq_results = fsq_client.search_venues(ll: [photo.image_lat, photo.image_lng].join(","))
      rescue => ex
        logger.error ex.message
        fsq_results = nil
      end
      if fsq_results and fsq_results.venues.length > 0
        fsq_spot = fsq_results.venues[0]
        if spot = Spot.find_or_create_by_fsq_spot_id(fsq_spot.id)
          review.spot_id = spot.id
        end
      end
    end
    if review.save
      return review
    else
      loger.error "#{self.class.to_s}##{__method__.to_s}: #{review.errors.inspect}}"
      raise "ERROR: " + review.errors
    end
  end

  def link_url
    "/tripnotes/#{self.tripnote.id}#episode-#{self.id}"
  end

  def image_url( size = :thumb )
    if self.main_photo
      # TODO: possible change to select flagged photo
      self.main_photo.image.url( size )
    else
      WAITING_UPLOAD_URL
    end
  end
  alias :thumbnail_url :image_url

  def main_photo
    if self.user_photos.size > 0
      # TODO: possible change to select flagged photo
      self.user_photos.first
    end
  end
end
