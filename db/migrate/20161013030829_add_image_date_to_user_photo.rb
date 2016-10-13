class AddImageDateToUserPhoto < ActiveRecord::Migration
  def change
    add_column :user_photos, :image_date, :datetime
    add_column :user_photos, :tripnote_id, :integer
    add_column :user_reviews, :tripnote_date, :datetime
    rename_column :user_reviews, :description, :body
  end
end
