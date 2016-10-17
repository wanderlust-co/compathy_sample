class AddColumnsToUserPhotos < ActiveRecord::Migration
  def change
    add_column :user_photos, :image_lat, :float
    add_column :user_photos, :image_lng, :float
  end
end
