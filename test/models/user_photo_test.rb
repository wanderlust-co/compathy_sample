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

require 'test_helper'

class UserPhotoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
