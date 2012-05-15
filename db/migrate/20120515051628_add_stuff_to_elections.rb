class AddStuffToElections < ActiveRecord::Migration
  def change
    add_column :elections, :erecords, :string

    add_column :elections, :elogs, :string

    add_column :elections, :evoters, :string

  end
end
