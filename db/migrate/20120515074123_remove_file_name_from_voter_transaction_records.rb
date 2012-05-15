class RemoveFileNameFromVoterTransactionRecords < ActiveRecord::Migration
  def up
    remove_column :voter_transaction_records, :file_name
      end

  def down
    add_column :voter_transaction_records, :file_name, :string
  end
end
