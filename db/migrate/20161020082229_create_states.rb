class CreateStates < ActiveRecord::Migration
  def change
    create_table :states do |t|
      t.string :cc, limit: 2, null: false
      t.string :name, null: false
      t.string :description
      t.string :url_name, limit: 2000, null: false
      t.float :lat, limit: 24
      t.float :lng, limit: 24
      t.string :thumbnail_url
      t.integer :published_tripnotes_count, default: 0, null: false
      t.string :gg_type

      t.timestamps
    end
  end
end
