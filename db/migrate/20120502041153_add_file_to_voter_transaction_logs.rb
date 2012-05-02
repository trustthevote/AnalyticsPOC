class AddFileToVoterTransactionLogs < ActiveRecord::Migration
  def change
    add_column :voter_transaction_logs, :file_name, :string

  end
end
