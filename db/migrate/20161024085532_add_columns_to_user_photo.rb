class AddColumnsToUserPhoto < ActiveRecord::Migration
  def change
    add_column :user_photos, :spot_id, :integer
    add_column :user_photos, :image_title, :string
    add_column :user_photos, :center_x, :decimal, precision: 10, scale: 2
    add_column :user_photos, :center_y, :decimal, precision: 10, scale: 2
    add_column :user_photos, :client_file_identifier, :string, limit: 1024
    add_column :user_photos, :compress_status, :string, default: "uncompressed"
  end
end
