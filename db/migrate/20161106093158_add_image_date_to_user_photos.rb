class AddImageDateToUserPhotos < ActiveRecord::Migration
  def change
    add_column :user_photos, :image_date, :datetime
  end
end
