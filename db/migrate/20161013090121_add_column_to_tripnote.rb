class AddColumnToTripnote < ActiveRecord::Migration
  def change
    add_column :tripnotes, :user_photo_id, :integer
  end
end
