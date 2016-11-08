class CreatePlanItems < ActiveRecord::Migration
  def change
    create_table :plan_items do |t|
      t.integer :plan_id
      t.integer :spot_id
      t.text :body

      t.timestamps
    end
  end
end
