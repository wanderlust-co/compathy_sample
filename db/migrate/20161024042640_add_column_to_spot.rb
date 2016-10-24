class AddColumnToSpot < ActiveRecord::Migration
  def change
    add_column :spots, :is_hotel, :boolean, default: false
  end
end
