class AddPublishedEpisodesCountToSpots < ActiveRecord::Migration
  def change
    add_column :spots, :published_episodes_count, :integer, default: 0, null: false
  end
end
