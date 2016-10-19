# == Schema Information
#
# Table name: user_photos
#
#  id                 :integer          not null, primary key
#  user_review_id     :integer
#  user_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_date         :datetime
#  tripnote_id        :integer
#

class UserPhoto < ActiveRecord::Base
  belongs_to :user
  belongs_to :tripnote
  belongs_to :user_review
  belongs_to :user_photo

  has_attached_file :image,
                    styles: {
                      thumb: '200x200#',
                      medium: '600x600^',
                      large: '1300x690#'
                    },
                    source_file_options: {
                      thumb: "-define jpeg:size=200x200",
                      medium: "-define jpeg:size=600x600",
                      large: "-define jpeg:size=1300x690"
                    }

  validates_attachment_content_type :image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  after_image_post_process :update_photo_info

  def authenticated_image_url(style)
    image.s3_object(style).url_for(:read, :secure => true)
  end

  # def thumbnail_url
  #   file_uploaded? ? self.image.url(:thumb) : nil
  # end

  # def medium_url
  #   file_uploaded? ? self.image.url(:medium) : WAITING_UPLOAD_URL
  # end

  # def large_url
  #   file_uploaded? ? self.image.url(:large) : WAITING_UPLOAD_URL
  # end

  def update_photo_info
    return unless image.queued_for_write[:original]

    EXIFR::TIFF.mktime_proc = proc{|*args| Time.zone.local(*args)}
    img = EXIFR::JPEG.new( self.image.queued_for_write[:original].path )
    return if img.nil? or not img.exif?

    self.image_date = img.date_time_original
    self.image_lat  = img.gps.latitude  if img.gps and not img.gps.latitude.nan?
    self.image_lng  = img.gps.longitude if img.gps and not img.gps.longitude.nan?

  rescue EXIFR::MalformedJPEG
    return nil
  rescue => ex
    raise ex.message
  end
end
