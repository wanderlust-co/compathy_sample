class CreatePlanItemMappings < ActiveRecord::Migration
  def change
    create_table :plan_item_mappings do |t|
      t.integer :plan_id
      t.integer :plan_item_id
      t.date :date
      t.integer :order

      t.timestamps
    end
  end
end
