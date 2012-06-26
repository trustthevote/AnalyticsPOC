class AddAnotherFieldToVoterRecords < ActiveRecord::Migration
  def change
    add_column :voter_records, :status, :string

  end
end
