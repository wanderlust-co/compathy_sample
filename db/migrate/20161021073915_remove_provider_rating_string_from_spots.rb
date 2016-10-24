class RemoveProviderRatingStringFromSpots < ActiveRecord::Migration
  def change
    remove_column :spots, :provider_rating_string, :string
  end
end
