class AddMoreFieldsToVoterRecords < ActiveRecord::Migration
  def change
    add_column :voter_records, :military, :string

    add_column :voter_records, :overseas, :string

    add_column :voter_records, :absentee, :string

    add_column :voter_records, :regidate, :date

  end
end
