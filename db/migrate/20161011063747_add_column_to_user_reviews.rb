class AddColumnToUserReviews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :user_id, :integer
  end
end
