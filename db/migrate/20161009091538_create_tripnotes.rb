class CreateTripnotes < ActiveRecord::Migration
  def change
    create_table :tripnotes do |t|
      t.string :title
      t.text :description
      t.integer :episode_id
      t.integer :user_id

      t.timestamps
    end
  end
end
