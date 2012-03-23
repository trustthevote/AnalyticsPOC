class AddDetailsToElections < ActiveRecord::Migration
  def change
    add_column :elections, :voter_end_day, :date

    add_column :elections, :voter_start_day, :date

    add_column :elections, :display_name, :string

  end
end
