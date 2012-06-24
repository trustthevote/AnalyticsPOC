class AddStuffToVoterRecords < ActiveRecord::Migration
  def change
    add_column :voter_records, :other, :string

  end
end
