class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes do |t|
      t.integer  "user_id",                    null: false
      t.string   "like_type",     limit: 100,  null: false
      t.integer  "like_id",                    null: false
      t.string   "fb_story_id"
      t.string   "cc",            limit: 2
      t.string   "created_by_ua", limit: 1000

      t.timestamps
    end
  end
end
