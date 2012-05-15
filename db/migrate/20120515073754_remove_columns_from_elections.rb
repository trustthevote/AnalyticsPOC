class RemoveColumnsFromElections < ActiveRecord::Migration
  def up
    remove_column :elections, :logs
        remove_column :elections, :records
        remove_column :elections, :voters
      end

  def down
    add_column :elections, :voters, :string
    add_column :elections, :records, :string
    add_column :elections, :logs, :string
  end
end
