class AddSpotIdToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :spot_id, :integer
  end
end
