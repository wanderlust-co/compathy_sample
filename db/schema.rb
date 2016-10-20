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

ActiveRecord::Schema.define(version: 20161020062906) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree

  create_table "cities", force: true do |t|
    t.string   "name",                       null: false
    t.string   "cc",            limit: 2,    null: false
    t.integer  "state_id"
    t.string   "description"
    t.string   "url_name",      limit: 2000, null: false
    t.float    "lat",           limit: 24
    t.float    "lng",           limit: 24
    t.string   "thumbnail_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "continents", force: true do |t|
    t.string   "name",                     null: false
    t.string   "url_name",                 null: false
    t.string   "continent_code", limit: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "countries", force: true do |t|
    t.string   "cc",                        limit: 2,               null: false
    t.string   "continent_code",            limit: 2,               null: false
    t.string   "area_in_sq_km"
    t.integer  "population"
    t.string   "currency_code"
    t.string   "languages"
    t.integer  "country_geoname_id"
    t.string   "west"
    t.string   "north"
    t.string   "east"
    t.string   "south"
    t.float    "lat",                       limit: 24
    t.float    "lng",                       limit: 24
    t.string   "url_name",                  limit: 191,             null: false
    t.string   "image_url"
    t.string   "name",                                              null: false
    t.string   "thumbnail_url"
    t.integer  "published_tripnotes_count",             default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "country_translations", force: true do |t|
    t.string   "cc",          limit: 2,        null: false
    t.string   "name",                         null: false
    t.string   "locale",                       null: false
    t.text     "description", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "state_translations", force: true do |t|
    t.integer  "state_id",                     null: false
    t.string   "name",                         null: false
    t.string   "locale",                       null: false
    t.text     "description", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", force: true do |t|
    t.string   "cc",                        limit: 2,                null: false
    t.string   "name",                                               null: false
    t.string   "description"
    t.string   "url_name",                  limit: 2000,             null: false
    t.float    "lat",                       limit: 24
    t.float    "lng",                       limit: 24
    t.string   "thumbnail_url"
    t.integer  "published_tripnotes_count",              default: 0, null: false
    t.string   "gg_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tripnotes", force: true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "user_review_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_photo_id"
  end

  create_table "user_photos", force: true do |t|
    t.integer  "user_review_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "image_date"
    t.integer  "tripnote_id"
    t.float    "image_lat",          limit: 24
    t.float    "image_lng",          limit: 24
  end

  create_table "user_reviews", force: true do |t|
    t.text     "body"
    t.integer  "price"
    t.integer  "user_photo_id"
    t.integer  "tripnote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.datetime "tripnote_date"
  end

  create_table "users", force: true do |t|
    t.string   "email",            null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
    t.string   "name"
    t.integer  "birthday"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "locale"
    t.integer  "tripnote_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
