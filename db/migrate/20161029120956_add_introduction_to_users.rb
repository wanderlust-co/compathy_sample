class AddIntroductionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :introduction, :text, limit: 16777215
  end
end
