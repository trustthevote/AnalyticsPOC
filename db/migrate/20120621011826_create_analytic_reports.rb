class CreateAnalyticReports < ActiveRecord::Migration
  def change
    create_table :analytic_reports do |t|
      t.integer :num
      t.date :day
      t.string :name
      t.string :desc
      t.text :data
      t.integer :val
      t.string :info
      t.boolean :test
      t.references :election

      t.timestamps
    end
    add_index :analytic_reports, :election_id
  end
end
