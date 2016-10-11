class CreateUserPhotos < ActiveRecord::Migration
  def change
    create_table :user_photos do |t|
      t.integer :user_review_id
      t.integer :user_id

      t.timestamps
    end
  end
end
