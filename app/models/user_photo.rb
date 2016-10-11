class UserPhoto < ActiveRecord::Base
  belongs_to :user
  belongs_to :tripnote
  belongs_to :user_review

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

  def authenticated_image_url(style)
    image.s3_object(style).url_for(:read, :secure => true)
  end
end
