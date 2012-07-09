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

ActiveRecord::Schema.define(:version => 20120709222157) do

  create_table "analytic_reports", :force => true do |t|
    t.integer  "num"
    t.date     "day"
    t.string   "name"
    t.string   "desc"
    t.text     "data"
    t.integer  "val"
    t.string   "info"
    t.boolean  "test"
    t.integer  "election_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "analytic_reports", ["election_id"], :name => "index_analytic_reports_on_election_id"

  create_table "elections", :force => true do |t|
    t.string   "name"
    t.date     "day"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "voter_end_day"
    t.date     "voter_start_day"
    t.boolean  "archived"
    t.string   "erecords"
    t.string   "elogs"
    t.string   "evoters"
    t.boolean  "selected"
    t.string   "log_file_names"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "voter_records", :force => true do |t|
    t.string   "vname"
    t.string   "vtype"
    t.string   "gender"
    t.string   "party"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "other"
    t.string   "status"
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
  end

  add_index "voter_transaction_records", ["voter_id"], :name => "index_voter_transaction_records_on_voter_id"
  add_index "voter_transaction_records", ["voter_transaction_log_id"], :name => "index_voter_transaction_records_on_voter_transaction_log_id"

  create_table "voters", :force => true do |t|
    t.string   "vname"
    t.string   "vtype"
    t.boolean  "voted"
    t.boolean  "vote_reject"
    t.string   "vote_form"
    t.string   "vote_note"
    t.string   "vuniq"
    t.integer  "election_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "vgender"
    t.string   "vparty"
    t.string   "vother"
    t.string   "vupdate"
    t.string   "vabsreq"
    t.boolean  "vonline"
    t.string   "vstatus"
    t.boolean  "vnew"
    t.string   "vregister"
    t.text     "vtr_state"
    t.integer  "votes"
  end

  add_index "voters", ["election_id"], :name => "index_voters_on_election_id"

end
