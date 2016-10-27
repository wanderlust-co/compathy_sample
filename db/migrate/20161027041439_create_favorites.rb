class CreateFavorites < ActiveRecord::Migration
  def change
    create_table :favorites do |t|
      t.integer  "user_id",     null: false
      t.integer  "tripnote_id", null: false
      t.string   "fb_story_id"

      t.timestamps
    end
  end
end
