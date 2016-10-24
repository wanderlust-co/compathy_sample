class CreateProviderCategories < ActiveRecord::Migration
  def change
    create_table :provider_categories do |t|
      t.string :name, null: false
      t.string :provider, null: false
      t.string :provider_category_id, null: false
      t.integer :level, null: false
      t.integer :cat1_code
      t.integer :cat2_code
      t.integer :cat3_code
      t.string :url_name, null: false

      t.timestamps
    end

    add_index :provider_categories, :name, length: 10
    add_index :provider_categories, :url_name, length: 10
  end
end