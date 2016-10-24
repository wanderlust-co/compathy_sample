class CreateSpotCategories < ActiveRecord::Migration
  def change
    create_table :spot_categories do |t|
      t.integer :spot_id
      t.integer :category_id

      t.timestamps
    end
  end
end
