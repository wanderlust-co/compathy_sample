class AddColumnsToUserReViews < ActiveRecord::Migration
  def change
    add_column :user_reviews, :retention_flag_for_reviewed_spot, :boolean, default: false, null: false
    add_column :user_reviews, :retention_flag_for_bookmarked_spot, :boolean, default: false, null: false
    add_column :user_reviews, :likes_count, :integer, default: 0
    add_column :user_reviews, :comments_count, :integer, default: 0
    add_column :user_reviews, :rough, :boolean, default: true,  null: false
  end
end
