class AddOpennessToTripnote < ActiveRecord::Migration
  def change
    add_column :tripnotes, :openness, :integer, index: true, null: false, default: 0
  end
end
