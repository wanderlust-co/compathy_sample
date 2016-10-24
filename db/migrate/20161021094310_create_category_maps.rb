class CreateCategoryMaps < ActiveRecord::Migration
  def change
    create_table :category_maps do |t|
      t.integer  :category_id, null: false
      t.integer  :provider_category_id, null: false

      t.timestamps
    end
  end
end
