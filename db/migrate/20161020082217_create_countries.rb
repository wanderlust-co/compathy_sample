class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :cc, limit: 2, null: false
      t.string :continent_code, limit: 2, null: false
      t.string :area_in_sq_km
      t.integer :population
      t.string :currency_code
      t.string :languages
      t.integer :country_geoname_id
      t.string :west
      t.string :north
      t.string :east
      t.string :south
      t.float :lat, limit: 24
      t.float :lng, limit: 24
      t.string :url_name, limit: 191, null: false
      t.string :image_url
      t.string :name, null: false
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
