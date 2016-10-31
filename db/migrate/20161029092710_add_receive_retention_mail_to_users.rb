class AddReceiveRetentionMailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :receive_retention_mail, :boolean, default: true,  null: false
  end
end
