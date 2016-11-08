class AddProviderPhotoUrlToSpots < ActiveRecord::Migration
  def change
    add_column :spots, :provider_photo_url, :string, limit: 2000
  end
end
