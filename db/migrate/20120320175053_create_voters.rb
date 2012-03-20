class CreateVoters < ActiveRecord::Migration
  def change
    create_table :voters do |t|
      t.string :voter
      t.string :vtype
      t.boolean :voted
      t.boolean :vrejected
      t.string :vform
      t.string :vnote
      t.string :uniq
      t.references :election

      t.timestamps
    end
    add_index :voters, :election_id
  end
end
