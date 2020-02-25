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

ActiveRecord::Schema.define(version: 2020_02_25_160620) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "allocated_periods_managements", force: :cascade do |t|
    t.bigint "curriculum_id"
    t.bigint "course_periods_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_periods_id"], name: "index_allocated_periods_managements_on_course_periods_id"
    t.index ["curriculum_id"], name: "index_allocated_periods_managements_on_curriculum_id"
  end

  create_table "course_periods", force: :cascade do |t|
    t.string "period_code"
    t.string "day_of_week"
    t.string "th_period"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "curriculums", force: :cascade do |t|
    t.string "name"
    t.string "registration_code", null: false
    t.string "start_time"
    t.string "teacher"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "semester"
    t.integer "participants_num"
    t.float "grade_a"
    t.float "grade_b"
    t.float "grade_c"
    t.float "grade_d"
    t.float "grade_e"
    t.float "grade_other"
    t.float "average_grade"
    t.string "faculty"
    t.string "department"
    t.string "start_year"
    t.integer "level"
    t.string "main_teacher_name"
    t.integer "credits"
    t.string "keywords"
  end

  create_table "evaluation_criteria", force: :cascade do |t|
    t.float "evaluation_attendance"
    t.float "evaluation_report", null: false
    t.float "evaluation_class_participation"
    t.float "evaluation_final_exam"
    t.float "evaluation_midterm_exam"
    t.float "evaluation_regular_exam"
    t.float "evaluation_reaction_paper"
    t.float "evaluation_short_test"
    t.float "evaluation_others"
    t.bigint "curriculum_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["curriculum_id"], name: "index_evaluation_criteria_on_curriculum_id"
  end

  add_foreign_key "allocated_periods_managements", "course_periods", column: "course_periods_id"
  add_foreign_key "allocated_periods_managements", "curriculums"
  add_foreign_key "evaluation_criteria", "curriculums"
end
