class RemoveNalllogsFromElections < ActiveRecord::Migration
  def up
    remove_column :elections, :nalllogs
      end

  def down
    add_column :elections, :nalllogs, :string
  end
end
