class AddDetailsToVoterTransactionRecords < ActiveRecord::Migration
  def change
    change_table :voter_transaction_records do |t|
      t.references :voter
    end
    add_index :voter_transaction_records, :voter_id
  end
end
