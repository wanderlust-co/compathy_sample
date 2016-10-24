class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :url_name, null: false
      t.integer :level, null: false
      t.integer :cat0_code
      t.integer :cat1_code
      t.integer :cat2_code
      t.integer :cat3_code

      t.timestamps
    end
  end
end
