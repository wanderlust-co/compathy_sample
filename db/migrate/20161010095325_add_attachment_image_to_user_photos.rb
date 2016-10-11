class AddAttachmentImageToUserPhotos < ActiveRecord::Migration
  def self.up
    change_table :user_photos do |t|
      t.has_attached_file :image
    end
  end

  def self.down
    drop_attached_file :user_photos, :image
  end
end
