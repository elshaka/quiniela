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

ActiveRecord::Schema.define(version: 20140625183030) do

  create_table "countries", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id",   default: 1, null: false
    t.integer  "points",     default: 0
    t.integer  "pj",         default: 0
    t.integer  "pg",         default: 0
    t.integer  "pe",         default: 0
    t.integer  "pp",         default: 0
    t.integer  "gf",         default: 0
    t.integer  "gc",         default: 0
    t.integer  "dif",        default: 0
  end

  create_table "games", force: true do |t|
    t.integer  "number"
    t.integer  "type"
    t.date     "date"
    t.integer  "country1_id"
    t.integer  "country1_goals"
    t.integer  "country2_id"
    t.integer  "country2_goals"
    t.boolean  "defined",        default: false
    t.boolean  "played",         default: false
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "predictions", force: true do |t|
    t.integer  "user_id"
    t.integer  "game_id"
    t.integer  "country1_id"
    t.integer  "country2_id"
    t.integer  "country1_goals"
    t.integer  "country2_goals"
    t.integer  "points"
    t.boolean  "done",           default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
