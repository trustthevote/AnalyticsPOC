class AddMoreFieldsToVoterTransactionRecords < ActiveRecord::Migration
  def change
    add_column :voter_transaction_records, :comment, :string

  end
end
