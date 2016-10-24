class CreateSpotRoutes < ActiveRecord::Migration
  def change
    create_table :spot_routes do |t|
      t.integer "origin_spot_id",                       null: false
      t.integer "destination_spot_id",                  null: false
      t.string  "route_name"
      t.float   "distance"
      t.integer "duration"
      t.float   "price"
      t.string  "currency",                             null: false
      t.text    "route_path",          limit: 16777215, null: false

      t.timestamps
    end
  end
end
