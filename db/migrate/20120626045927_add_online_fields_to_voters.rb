class AddOnlineFieldsToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vonline, :boolean

  end
end
