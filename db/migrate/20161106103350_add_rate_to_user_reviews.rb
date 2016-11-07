class AddRateToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :rate, :float, limit: 24
  end
end
