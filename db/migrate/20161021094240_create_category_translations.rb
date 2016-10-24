class CreateCategoryTranslations < ActiveRecord::Migration
  def change
    create_table :category_translations do |t|
      t.integer :category_id
      t.string :locale, null: false
      t.string :name, null: false
      t.timestamps
    end
  end
end
