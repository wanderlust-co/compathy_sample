class CreateStateTranslations < ActiveRecord::Migration
  def change
    create_table :state_translations do |t|
      t.integer :state_id, null: false
      t.string :name, null: false
      t.string :locale, null: false
      t.text :description, limit: 16777215

      t.timestamps
    end
  end
end
