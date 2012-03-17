class CreateVoterTransactionLogs < ActiveRecord::Migration
  def change
    create_table :voter_transaction_logs do |t|
      t.string :origin
      t.string :origin_uniq
      t.datetime :datime
      t.references :election

      t.timestamps
    end
    add_index :voter_transaction_logs, :election_id
  end
end
