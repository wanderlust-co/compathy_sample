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

class User < ActiveRecord::Base
  authenticates_with_sorcery! do |config|
    config.authentications_class = Authentication
  end

  has_many :authentications, :dependent => :destroy
  has_many :tripnotes
  has_many :user_reviews
  accepts_nested_attributes_for :authentications

  validates :password, length: { minimum: 3 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password, confirmation: true, if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence: true, if: -> { new_record? || changes[:crypted_password] }

  validates :email, uniqueness: true

  def attr_accessible
    params.require(:user).permit(:email, :password, :password_confirmation, :authentications_attributes)
  end

  def fb_user_id
    if auth = self.authentications.find_by( provider: "facebook" )
      auth.uid
    end
  end

  def thumbnail_url( square_size: 80 )
    return self.image_url if self.image_url.present?

    "https://graph.facebook.com/#{self.fb_user_id}/picture?width=#{square_size}&height=#{square_size}"
  end
end
