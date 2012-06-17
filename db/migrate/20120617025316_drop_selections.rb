class DropSelections < ActiveRecord::Migration
  def change
    drop_table :selections
  end
end
