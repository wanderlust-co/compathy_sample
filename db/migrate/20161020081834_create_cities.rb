class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name, null: false
      t.string :cc, limit: 2, null: false
      t.integer :state_id
      t.string :description
      t.string :url_name, limit: 2000, null: false
      t.float :lat, limit: 24
      t.float :lng, limit: 24
      t.string :thumbnail_url

      t.timestamps
    end
  end
end
