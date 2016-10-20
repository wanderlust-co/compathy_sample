class CreateCountryTranslations < ActiveRecord::Migration
  def change
    create_table :country_translations do |t|
      t.string :cc, limit: 2, null: false
      t.string :name, null: false
      t.string :locale, null: false
      t.text :description, limit: 16777215

      t.timestamps
    end
  end
end
