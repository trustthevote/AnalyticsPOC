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

ActiveRecord::Schema.define(:version => 20120308044749) do

  create_table "election_logs", :force => true do |t|
    t.string   "election"
    t.date     "day"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "elections", :force => true do |t|
    t.string   "name"
    t.date     "day"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "selections", :force => true do |t|
    t.integer  "eid"
    t.string   "ename"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "voter_transaction_logs", :force => true do |t|
    t.string   "origin"
    t.string   "origin_uniq"
    t.datetime "datime"
    t.string   "locale"
    t.integer  "election_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "voter_transaction_logs", ["election_id"], :name => "index_voter_transaction_logs_on_election_id"

  create_table "voter_transaction_records", :force => true do |t|
    t.string   "voter"
    t.string   "vtype"
    t.datetime "datime"
    t.string   "action"
    t.text     "form"
    t.string   "leo"
    t.string   "note"
    t.integer  "voter_transaction_log_id"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "voter_transaction_records", ["voter_transaction_log_id"], :name => "index_voter_transaction_records_on_voter_transaction_log_id"

end
