class AddColumnsToTripnotes < ActiveRecord::Migration
  def change
    add_column :tripnotes, :favorites_count, :integer, default: 0
  end
end
