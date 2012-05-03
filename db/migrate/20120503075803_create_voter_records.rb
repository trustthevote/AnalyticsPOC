class CreateVoterRecords < ActiveRecord::Migration
  def change
    create_table :voter_records do |t|
      t.string :vname
      t.string :vtype
      t.string :gender
      t.string :party

      t.timestamps
    end
  end
end
