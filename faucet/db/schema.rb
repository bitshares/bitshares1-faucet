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

ActiveRecord::Schema.define(version: 4) do

  create_table "assets", force: true do |t|
    t.integer  "assetid"
    t.string   "symbol"
    t.string   "name"
    t.string   "description"
    t.integer  "precision"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "assets", ["assetid"], name: "index_assets_on_assetid", unique: true, using: :btree
  add_index "assets", ["symbol"], name: "index_assets_on_symbol", unique: true, using: :btree

  create_table "bts_accounts", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "key"
    t.string   "referrer"
    t.string   "ogid"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bts_accounts", ["name"], name: "index_bts_accounts_on_name", unique: true, using: :btree
  add_index "bts_accounts", ["ogid"], name: "index_bts_accounts_on_ogid", unique: true, using: :btree
  add_index "bts_accounts", ["user_id"], name: "index_bts_accounts_on_user_id", using: :btree

  create_table "identities", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "identities", ["provider", "uid"], name: "index_identities_on_provider_and_uid", unique: true, using: :btree
  add_index "identities", ["user_id"], name: "index_identities_on_user_id", using: :btree

  create_table "referral_codes", force: true do |t|
    t.string   "code"
    t.string   "account_name"
    t.integer  "ref_code_id"
    t.integer  "asset_id"
    t.integer  "amount",        limit: 8
    t.datetime "expires_at"
    t.boolean  "funded"
    t.string   "prerequisites"
    t.datetime "redeemed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "referral_codes", ["asset_id"], name: "index_referral_codes_on_asset_id", using: :btree
  add_index "referral_codes", ["code"], name: "index_referral_codes_on_code", unique: true, using: :btree
  add_index "referral_codes", ["ref_code_id"], name: "index_referral_codes_on_ref_code_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                    default: "",    null: false
    t.string   "email",                   default: ""
    t.string   "encrypted_password",      default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.boolean  "is_admin",                default: false
    t.string   "newsletter_subscription"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
