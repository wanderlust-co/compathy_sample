class Like < ActiveRecord::Base
  belongs_to :user, touch: true

  # NOTE: not using touch/counter_cache here, because of Polymorphic relation. (should use Rails polymorphic ?)
  belongs_to :user_review, -> { joins(:likes) }, foreign_key: "like_id"

  # has_many :notifications, dependent: :delete_all
  # has_many :activities, -> { where( actv_type: CY_ACTV_TYPE_LIKE ) }, foreign_key: "actv_id", dependent: :destroy

  validates :user_id,
    :presence => true,
    :uniqueness => { :scope => [:like_type, :like_id] }
  validates :like_type, presence: true
  validates :like_id, presence: true

  after_create  :increment_counter
  before_destroy :decrement_counter, prepend: true

  scope :opened, -> {
    joins("INNER JOIN user_reviews ON user_reviews.id = likes.like_id").
    joins("INNER JOIN tripnotes ON tripnotes.id = user_reviews.tripnote_id AND (tripnotes.openness > 0)")
  }

  def users_liked_same_object
    User.joins(:likes).where( "likes.like_type = ? AND likes.like_id = ?", self.like_type, self.like_id ).uniq
  end

  def send_retention_mail
    return unless self.like_type == CY_LIKE_TYPE_REVIEW

    user_review = self.user_review
    user_review_owner = user_review.user
    # return if self.user == user_review_owner
    return unless user_review_owner.receive_retention_mail
    return unless user_review_owner.email

    UserMailer.delay.like_user_review( user_review_owner, self.user, user_review )
    # binding.pry
  end

  def send_mobile_notification
    user_review  = self.user_review
    user_review_owner = user_review.user
    return if self.user == user_review_owner
    notif = Notification.create!( user_id: user_review_owner.id, nf_type: CYSH_NOTIFY_TYPES[:like_review], nf_template: "like_user_review", tripnote_id: user_review.tripnote_id, user_review_id: user_review.id, like_id: self.id, other_user: self.user )
    notif.push_to_user
  end

  private

  def increment_counter
    case self.like_type
    when CY_LIKE_TYPE_REVIEW
      self.reload.user_review.increment!(:likes_count)
    end
  end

  def decrement_counter
    case self.like_type
    when CY_LIKE_TYPE_REVIEW
      self.reload.user_review.decrement!(:likes_count)
    end
  end
end

