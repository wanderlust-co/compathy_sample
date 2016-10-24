class CreateLinkedStates < ActiveRecord::Migration
  def change
    create_table :linked_states do |t|
      t.integer :state_id
      t.integer :linked_id

      t.timestamps
    end
  end
end
