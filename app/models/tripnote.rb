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

  def cover_photo
    if user_photo_id
      if user_photo = UserPhoto.find(user_photo_id)
        return user_photo
      end
    end
    nil
  end
end
