class RenameAdsUrlNameToSpots < ActiveRecord::Migration
  def change
    rename_column :spots, :ads_url_name, :abs_url_name
  end
end
