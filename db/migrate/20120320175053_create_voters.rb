class CreateVoters < ActiveRecord::Migration
  def change
    create_table :voters do |t|
      t.string :vname
      t.string :vtype
      t.boolean :voted
      t.boolean :vreject
      t.string :vform
      t.string :vnote
      t.string :vuniq
      t.references :election

      t.timestamps
    end
    add_index :voters, :election_id
  end
end
