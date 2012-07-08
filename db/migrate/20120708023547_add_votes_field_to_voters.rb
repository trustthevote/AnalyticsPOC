class AddVotesFieldToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :votes, :integer

  end
end
