class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.integer :user_id, null: false
      t.string :title
      t.text :description
      t.date :date_from, null: false
      t.date :date_to, null: false
      t.string :main_cc, limit: 2
      t.integer :main_stat_id
      t.datetime :published_at
      t.string :public_link_key, limit: 40

      t.timestamps
    end
  end
end
