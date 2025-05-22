# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_21_234739) do
  create_table "groups", force: :cascade do |t|
    t.string "group_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "subject_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "teachers", force: :cascade do |t|
    t.string "teacher_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "timetables", force: :cascade do |t|
    t.integer "subject_id", null: false
    t.integer "group_id", null: false
    t.integer "teacher_id", null: false
    t.integer "day_of_week"
    t.integer "lesson_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_timetables_on_group_id"
    t.index ["subject_id"], name: "index_timetables_on_subject_id"
    t.index ["teacher_id"], name: "index_timetables_on_teacher_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "telegram_id"
    t.string "first_name"
    t.string "role"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state"
  end

  add_foreign_key "timetables", "groups"
  add_foreign_key "timetables", "subjects"
  add_foreign_key "timetables", "teachers"
end
