class AddVrToSelections < ActiveRecord::Migration
  def change
    add_column :selections, :vr_file, :string

    add_column :selections, :vr_origin, :string

  end
end
