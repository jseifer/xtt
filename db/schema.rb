# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 5) do

  create_table "accounts", :force => true do |t|
    t.string   "host"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["host"], :name => "index_accounts_on_host"

  create_table "projects", :force => true do |t|
    t.string   "name"
    t.boolean  "billable"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id"
  end

  add_index "projects", ["name", "account_id"], :name => "index_projects_on_name_and_account_id"

  create_table "statuses", :force => true do |t|
    t.integer  "user_id"
    t.decimal  "hours",      :default => 0.0
    t.string   "message"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  add_index "statuses", ["created_at", "user_id"], :name => "index_statuses_on_created_at_and_user_id"

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                   :default => "passive"
    t.datetime "deleted_at"
    t.integer  "account_id"
  end

  add_index "users", ["login", "account_id"], :name => "index_users_on_login_and_account_id"

end
