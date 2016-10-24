class CreateBookmarks < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.integer  "user_id",                     null: false
      t.integer  "bk_id",                       null: false
      t.string   "bk_type",                     null: false
      t.integer  "user_review_id"

      t.timestamps
    end
  end
end
