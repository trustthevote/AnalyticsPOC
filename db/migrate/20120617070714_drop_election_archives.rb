class DropElectionArchives < ActiveRecord::Migration
  def change
    drop_table :election_archives    
  end
end
