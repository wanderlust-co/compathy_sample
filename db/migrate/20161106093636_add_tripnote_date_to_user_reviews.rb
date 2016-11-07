class AddTripnoteDateToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :tripnote_date, :datetime, null: false
  end
end
