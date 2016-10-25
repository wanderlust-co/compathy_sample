class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :image_url, :string, limit: 2000
  end
end
