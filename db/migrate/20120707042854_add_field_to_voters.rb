class AddFieldToVoters < ActiveRecord::Migration
  def change
    add_column :voters, :vregister, :string
    add_column :voters, :vtr_state, :text
    rename_column :voters, :vnote, :vote_note
    rename_column :voters, :vreject, :vote_reject
    rename_column :voters, :vform, :vote_form
  end
end
