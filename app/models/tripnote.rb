# == Schema Information
#
# Table name: tripnotes
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  description    :text
#  user_review_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#  user_photo_id  :integer
#

class Tripnote < ActiveRecord::Base
  belongs_to :user
  has_many :user_reviews, dependent: :destroy
  belongs_to :user_photo

  has_many :comments, -> { where(cm_type: CY_CM_TYPE_TRIPNOTE) },
           foreign_key: "cm_id", dependent: :destroy

  def cover_photo
    if user_photo_id
      if user_photo = UserPhoto.find(user_photo_id)
        return user_photo
      end
    end
    nil
  end

  def link_url
    "/tripnotes/" + id.to_s
  end

  def open_full!
    update(openness: CY_OPENNESS[:full])
  end
  
  def draftize!
    update(openness: CY_OPENNESS[:draft])
  end
end
