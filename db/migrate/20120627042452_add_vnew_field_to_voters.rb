class AddVnewFieldToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vnew, :boolean

  end
end
