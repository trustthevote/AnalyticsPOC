class RemoveDisplayNameFromElections < ActiveRecord::Migration
  def up
    remove_column :elections, :display_name
      end

  def down
    add_column :elections, :display_name, :string
  end
end
