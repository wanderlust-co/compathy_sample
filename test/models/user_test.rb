# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)      not null
#  crypted_password :string(255)
#  salt             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  username         :string(255)
#  name             :string(255)
#  birthday         :integer
#  first_name       :string(255)
#  last_name        :string(255)
#  gender           :string(255)
#  locale           :string(255)
#  tripnote_id      :integer
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
