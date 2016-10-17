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

require 'test_helper'

class TripnoteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
