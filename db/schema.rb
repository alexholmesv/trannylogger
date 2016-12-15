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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161215161633) do

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.text     "address"
    t.string   "rut"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.integer  "client_id"
    t.string   "name"
    t.date     "date_received"
    t.integer  "words"
    t.float    "rate"
    t.float    "extras"
    t.float    "total"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "invoice_number"
    t.boolean  "sent"
    t.integer  "translator_id"
    t.boolean  "customer_payment"
    t.boolean  "translator_payment"
    t.text     "comments"
    t.integer  "translator_invoice"
  end

  add_index "projects", ["client_id"], name: "index_projects_on_client_id"
  add_index "projects", ["translator_id"], name: "index_projects_on_translator_id"

  create_table "translator_invoices", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "translator_id"
    t.integer  "invoice_number"
    t.date     "date"
    t.boolean  "project_sent"
    t.boolean  "invoice_sent"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "translator_invoices", ["project_id"], name: "index_translator_invoices_on_project_id"
  add_index "translator_invoices", ["translator_id"], name: "index_translator_invoices_on_translator_id"

  create_table "translators", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "project_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "name"
    t.string   "dropbox_session"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
