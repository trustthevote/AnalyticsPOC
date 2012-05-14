class AddNLogsToElections < ActiveRecord::Migration
  def change
    add_column :elections, :nalllogs, :integer

  end
end
