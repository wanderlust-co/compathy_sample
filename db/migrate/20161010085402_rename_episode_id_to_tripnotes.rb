class RenameEpisodeIdToTripnotes < ActiveRecord::Migration
  def change
    rename_column :tripnotes, :episode_id, :user_review_id
  end
end
