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

ActiveRecord::Schema.define(version: 2019_10_10_205101) do

  create_table "copyholders", force: :cascade do |t|
    t.string "copyholder"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hebid_copyholders", force: :cascade do |t|
    t.integer "hebid_id"
    t.integer "copyholder_id"
  end

  create_table "hebid_related_titles", force: :cascade do |t|
    t.integer "hebid_id"
    t.string "related_hebid"
    t.string "related_title"
    t.string "related_authors"
    t.string "related_pubinfo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hebid_reviews", force: :cascade do |t|
    t.integer "hebid_id"
    t.string "journal_abbrev"
    t.string "review_label"
    t.string "review_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hebid_series", force: :cascade do |t|
    t.integer "hebid_id"
    t.integer "series_id"
  end

  create_table "hebid_subjects", force: :cascade do |t|
    t.integer "hebid_id"
    t.integer "subject_id"
  end

  create_table "hebids", force: :cascade do |t|
    t.string "hebid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "series", force: :cascade do |t|
    t.string "series_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "subject_title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
