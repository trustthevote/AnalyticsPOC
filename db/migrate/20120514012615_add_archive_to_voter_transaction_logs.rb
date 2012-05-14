class AddArchiveToVoterTransactionLogs < ActiveRecord::Migration
  def change
    add_column :voter_transaction_logs, :archive_name, :string

  end
end
