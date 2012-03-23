class RemoveDetailsFromSelections < ActiveRecord::Migration
  def change
    remove_column :selections, :ename
  end
end
