class AddFieldsToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vupdate, :string

    add_column :voters, :vabsreq, :string

  end
end
