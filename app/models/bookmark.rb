class Bookmark < ActiveRecord::Base
  belongs_to :user
  belongs_to :user_review
  alias_attribute :episode, :user_review

  has_many :activities, -> { where( actv_type: CY_ACTV_TYPE_BOOKMARK ) }, foreign_key: "actv_id", dependent: :destroy

  validates :user_id,
    :presence => true,
    :uniqueness => { :scope => [:bk_type, :bk_id] }

  validates_presence_of :bk_type, :bk_id


  # FIXME: leave `opened` for information consistency of iOS
  #        but its problem for users using both of Web & iOS
  scope :opened, -> {
    joins("INNER JOIN user_reviews ON user_reviews.id = bookmarks.user_review_id").
    joins("INNER JOIN tripnotes ON tripnotes.id = user_reviews.tripnote_id AND (tripnotes.openness > 0)")
  }

  alias :review :user_review

  def bookmarks_count
    Bookmark.where( bk_type: self.bk_type, bk_id: self.bk_id ).count
  end

  def spot
    Spot.where( id: self.bk_id ).first
  end

  private
    def save_activity
      return if self.user.official_account?
      _action_type = CYSH_ACTION_TYPES[:bk_spot]
      Activity.create(
        action_type: _action_type,
        user_id:     self.user_id,
        actv_type:   CY_ACTV_TYPE_BOOKMARK,
        actv_id:     self.id
      )
    end
end

