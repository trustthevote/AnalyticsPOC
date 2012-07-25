class Add4morefieldstoElections < ActiveRecord::Migration
  def change
    add_column :elections, :deadline_vr_day, :date
    add_column :elections, :deadline_ar_day, :date
    add_column :elections, :deadline_45_day, :date
    add_column :elections, :deadline_br_day, :date
  end
end
