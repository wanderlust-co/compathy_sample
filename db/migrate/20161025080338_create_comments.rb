class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.string :cm_type, null: false
      t.integer :cm_id, null: false
      t.text :body, null: false

      t.timestamps
    end
  end
end
