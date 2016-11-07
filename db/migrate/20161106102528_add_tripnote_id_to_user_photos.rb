class AddTripnoteIdToUserPhotos < ActiveRecord::Migration
  def change
    add_column :user_photos, :tripnote_id, :integer
  end
end
