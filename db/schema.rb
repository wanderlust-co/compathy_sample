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

ActiveRecord::Schema.define(version: 20161103030449) do

  create_table "authentications", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "provider",   null: false
    t.string   "uid",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider", "uid"], name: "index_authentications_on_provider_and_uid", using: :btree

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",        null: false
    t.integer  "bk_id",          null: false
    t.string   "bk_type",        null: false
    t.integer  "user_review_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", force: true do |t|
    t.string   "name",       null: false
    t.string   "url_name",   null: false
    t.integer  "level",      null: false
    t.integer  "cat0_code"
    t.integer  "cat1_code"
    t.integer  "cat2_code"
    t.integer  "cat3_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_maps", force: true do |t|
    t.integer  "category_id",          null: false
    t.integer  "provider_category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "category_translations", force: true do |t|
    t.integer  "category_id"
    t.string   "locale",      null: false
    t.string   "name",        null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "comments", force: true do |t|
    t.integer  "user_id",    null: false
    t.string   "cm_type",    null: false
    t.integer  "cm_id",      null: false
    t.text     "body",       null: false
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
    t.string   "cc",                 limit: 2,   null: false
    t.string   "continent_code",     limit: 2,   null: false
    t.string   "area_in_sq_km"
    t.integer  "population"
    t.string   "currency_code"
    t.string   "languages"
    t.integer  "country_geoname_id"
    t.string   "west"
    t.string   "north"
    t.string   "east"
    t.string   "south"
    t.float    "lat",                limit: 24
    t.float    "lng",                limit: 24
    t.string   "url_name",           limit: 191, null: false
    t.string   "image_url"
    t.string   "name",                           null: false
    t.string   "thumbnail_url"
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

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "favorites", force: true do |t|
    t.integer  "user_id",     null: false
    t.integer  "tripnote_id", null: false
    t.string   "fb_story_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "liked_states", force: true do |t|
    t.integer  "state_id"
    t.integer  "linked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "likes", force: true do |t|
    t.integer  "user_id",                    null: false
    t.string   "like_type",     limit: 100,  null: false
    t.integer  "like_id",                    null: false
    t.string   "fb_story_id"
    t.string   "cc",            limit: 2
    t.string   "created_by_ua", limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "linked_states", force: true do |t|
    t.integer  "state_id"
    t.integer  "linked_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plans", force: true do |t|
    t.integer  "user_id",                    null: false
    t.string   "title"
    t.text     "description"
    t.date     "date_from",                  null: false
    t.date     "date_to",                    null: false
    t.string   "main_cc",         limit: 2
    t.integer  "main_state_id"
    t.datetime "published_at"
    t.string   "public_link_key", limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "provider_categories", force: true do |t|
    t.string   "name",                 null: false
    t.string   "provider",             null: false
    t.string   "provider_category_id", null: false
    t.integer  "level",                null: false
    t.integer  "cat1_code"
    t.integer  "cat2_code"
    t.integer  "cat3_code"
    t.string   "url_name",             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "provider_categories", ["name"], name: "index_provider_categories_on_name", length: {"name"=>10}, using: :btree
  add_index "provider_categories", ["url_name"], name: "index_provider_categories_on_url_name", length: {"url_name"=>10}, using: :btree

  create_table "spot_categories", force: true do |t|
    t.integer  "spot_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spot_routes", force: true do |t|
    t.integer  "origin_spot_id",                       null: false
    t.integer  "destination_spot_id",                  null: false
    t.string   "route_name"
    t.float    "distance",            limit: 24
    t.integer  "duration"
    t.float    "price",               limit: 24
    t.string   "currency",                             null: false
    t.text     "route_path",          limit: 16777215, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "spots", force: true do |t|
    t.string   "name",                                          null: false
    t.string   "address"
    t.string   "tel"
    t.float    "lat",              limit: 24,                   null: false
    t.float    "lng",              limit: 24,                   null: false
    t.string   "url"
    t.string   "cc",               limit: 2,                    null: false
    t.string   "provider_url",     limit: 2000
    t.integer  "provider",                                      null: false
    t.string   "provider_spot_id"
    t.string   "station"
    t.string   "take_time"
    t.string   "cost"
    t.string   "url_name",         limit: 2000,                 null: false
    t.string   "abs_url_name",     limit: 2000,                 null: false
    t.integer  "user_id"
    t.datetime "deleted_at"
    t.float    "rating",           limit: 24
    t.integer  "state_id"
    t.integer  "city_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider_rating",  limit: 24
    t.boolean  "is_hotel",                      default: false
  end

  add_index "spots", ["user_id"], name: "index_spots_on_user_id", using: :btree

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
    t.integer  "openness",        default: 0, null: false
    t.integer  "favorites_count", default: 0
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
    t.float    "image_lat",              limit: 24
    t.float    "image_lng",              limit: 24
    t.integer  "spot_id"
    t.string   "image_title"
    t.decimal  "center_x",                            precision: 10, scale: 2
    t.decimal  "center_y",                            precision: 10, scale: 2
    t.string   "client_file_identifier", limit: 1024
    t.string   "compress_status",                                              default: "uncompressed"
  end

  create_table "user_reviews", force: true do |t|
    t.text     "body"
    t.integer  "price"
    t.integer  "user_photo_id"
    t.integer  "tripnote_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "retention_flag_for_reviewed_spot",   default: false, null: false
    t.boolean  "retention_flag_for_bookmarked_spot", default: false, null: false
    t.integer  "likes_count",                        default: 0
    t.integer  "comments_count",                     default: 0
    t.boolean  "rough",                              default: true,  null: false
  end

  create_table "users", force: true do |t|
    t.string   "email",                                                   null: false
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
    t.string   "image_url",              limit: 2000
    t.boolean  "receive_retention_mail",                  default: true,  null: false
    t.text     "introduction",           limit: 16777215
    t.boolean  "active",                                  default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
