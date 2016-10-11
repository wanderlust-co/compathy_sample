class AddTripnoteIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tripnote_id, :integer
  end
end
