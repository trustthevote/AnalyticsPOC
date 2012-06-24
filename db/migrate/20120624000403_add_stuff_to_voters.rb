class AddStuffToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vgender, :string

    add_column :voters, :vparty, :string

    add_column :voters, :vother, :string

  end
end
