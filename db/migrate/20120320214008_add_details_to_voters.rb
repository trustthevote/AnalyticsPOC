class AddDetailsToVoters < ActiveRecord::Migration
  def change
    rename_column :voters, :voter, :vname
    rename_column :voters, :uniq, :vuniq
  end
end
