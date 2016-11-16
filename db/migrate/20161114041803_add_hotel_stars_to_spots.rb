class AddHotelStarsToSpots < ActiveRecord::Migration
  def change
    add_column :spots, :hotel_stars, :float, limit: 24
  end
end
