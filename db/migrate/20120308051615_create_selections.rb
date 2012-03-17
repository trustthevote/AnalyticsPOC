class CreateSelections < ActiveRecord::Migration
  def change
    create_table :selections do |t|
      t.integer :eid
      t.string :ename

      t.timestamps
    end
  end
end
