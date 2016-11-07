class AddCostToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :cost, :float, limit: 24
  end
end
