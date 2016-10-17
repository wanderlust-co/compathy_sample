class AddColumnToUserPhoto < ActiveRecord::Migration
  def change
    rename_column :user_reviews, :description, :body
  end
end
