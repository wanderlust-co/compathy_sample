class CreateContinents < ActiveRecord::Migration
  def change
    create_table :continents do |t|
      t.string :name, null: false
      t.string :url_name, null: false
      t.string :continent_code, limit: 2, null: false

      t.timestamps
    end
  end
end
