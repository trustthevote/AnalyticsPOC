class AddLogFileNamesToElections < ActiveRecord::Migration
  def change
    add_column :elections, :log_file_names, :string

  end
end
