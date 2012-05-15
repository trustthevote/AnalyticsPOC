# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120515051628) do

  create_table "elections", :force => true do |t|
    t.string   "name"
    t.date     "day"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "voter_end_day"
    t.date     "voter_start_day"
    t.string   "display_name"
    t.integer  "nalllogs"
    t.boolean  "archived"
    t.string   "voters"
    t.string   "records"
    t.string   "logs"
    t.string   "erecords"
    t.string   "elogs"
    t.string   "evoters"
  end

  create_table "selections", :force => true do |t|
    t.integer  "eid"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "vr_file"
    t.string   "vr_origin"
  end

  create_table "voter_records", :force => true do |t|
    t.string   "vname"
    t.string   "vtype"
    t.string   "gender"
    t.string   "party"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "voter_transaction_logs", :force => true do |t|
    t.string   "origin"
    t.string   "origin_uniq"
    t.datetime "datime"
    t.integer  "election_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "file_name"
    t.string   "archive_name"
  end

  add_index "voter_transaction_logs", ["election_id"], :name => "index_voter_transaction_logs_on_election_id"

  create_table "voter_transaction_records", :force => true do |t|
    t.string   "vname"
    t.string   "vtype"
    t.datetime "datime"
    t.string   "action"
    t.string   "fname"
    t.text     "form"
    t.string   "leo"
    t.string   "note"
    t.integer  "voter_transaction_log_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.integer  "voter_id"
    t.string   "file_name"
  end

  add_index "voter_transaction_records", ["voter_id"], :name => "index_voter_transaction_records_on_voter_id"
  add_index "voter_transaction_records", ["voter_transaction_log_id"], :name => "index_voter_transaction_records_on_voter_transaction_log_id"

  create_table "voters", :force => true do |t|
    t.string   "vname"
    t.string   "vtype"
    t.boolean  "voted"
    t.boolean  "vreject"
    t.string   "vform"
    t.string   "vnote"
    t.string   "vuniq"
    t.integer  "election_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "voters", ["election_id"], :name => "index_voters_on_election_id"

end
