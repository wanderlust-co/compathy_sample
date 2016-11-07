class AddTripnoteTotalOrderToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :tripnote_total_order, :integer
  end
end
