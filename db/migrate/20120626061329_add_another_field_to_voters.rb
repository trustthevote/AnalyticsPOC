class AddAnotherFieldToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vstatus, :string

  end
end
