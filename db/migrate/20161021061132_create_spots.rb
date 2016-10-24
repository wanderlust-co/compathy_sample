class CreateSpots < ActiveRecord::Migration
  def change
    create_table :spots do |t|
      t.string :name, null: false
      t.string :address
      t.string :tel
      t.float :lat, null: false
      t.float :lng, null: false
      t.string :url
      t.string :cc, limit: 2, null: false, index: true
      t.string :provider_url, limit: 2000
      t.integer :provider, null: false
      t.string :provider_spot_id
      t.string :station
      t.string :take_time
      t.string :cost
      t.string :url_name, limit: 2000, null: false
      t.string :ads_url_name, limit: 2000, null: false
      t.integer :user_id
      t.datetime :deleted_at
      t.float :rating
      t.string :provider_rating_string
      t.integer :state_id
      t.integer :city_id
      t.references :user, index: true

      t.timestamps
    end
  end
end
