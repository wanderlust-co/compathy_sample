class CreateUserReviews < ActiveRecord::Migration
  def change
    create_table :user_reviews do |t|
      t.text :description
      t.integer :price
      t.integer :user_photo_id
      t.integer :tripnote_id

      t.timestamps
    end
  end
end
