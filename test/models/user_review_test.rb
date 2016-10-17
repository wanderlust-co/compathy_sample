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

require 'test_helper'

class UserReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
