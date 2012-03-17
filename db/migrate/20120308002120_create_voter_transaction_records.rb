class CreateVoterTransactionRecords < ActiveRecord::Migration
  def change
    create_table :voter_transaction_records do |t|
      t.string :voter
      t.string :vtype
      t.datetime :datime
      t.string :action
      t.text :form
      t.string :leo
      t.string :note
      t.references :voter_transaction_log

      t.timestamps
    end
    add_index :voter_transaction_records, :voter_transaction_log_id
  end
end
