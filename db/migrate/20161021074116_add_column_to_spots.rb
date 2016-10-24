class AddColumnToSpots < ActiveRecord::Migration
  def change
    add_column :spots, :provider_rating, :string, limit: 24
  end
end
