class CreateElectionArchives < ActiveRecord::Migration
  def change
    create_table :election_archives do |t|
      t.string :name
      t.date :day
      t.date :voter_end_day
      t.date :voter_start_day
      t.integer :nlogs
      t.string :log_file_names

      t.timestamps
    end
  end
end
