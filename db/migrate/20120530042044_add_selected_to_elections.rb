class AddSelectedToElections < ActiveRecord::Migration
  def change
    add_column :elections, :selected, :boolean

  end
end
