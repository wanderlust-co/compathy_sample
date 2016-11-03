class RenameMainStatIdColumnToPlans < ActiveRecord::Migration
  def change
    rename_column :plans, :main_stat_id, :main_state_id
  end
end
