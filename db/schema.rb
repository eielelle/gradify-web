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

ActiveRecord::Schema[7.1].define(version: 2024_10_12_163417) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exams", force: :cascade do |t|
    t.string "name"
    t.bigint "quarter_id", null: false
    t.bigint "subject_id", null: false
    t.integer "items"
    t.string "answer_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quarter_id"], name: "index_exams_on_quarter_id"
    t.index ["subject_id"], name: "index_exams_on_subject_id"
  end

  create_table "quarters", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_classes", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_classes_users", id: false, force: :cascade do |t|
    t.bigint "school_class_id", null: false
    t.bigint "user_id", null: false
    t.index ["school_class_id"], name: "index_school_classes_users_on_school_class_id"
    t.index ["user_id"], name: "index_school_classes_users_on_user_id"
  end

  create_table "school_sections", force: :cascade do |t|
    t.bigint "school_year_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_year_id"], name: "index_school_sections_on_school_year_id"
  end

  create_table "school_sections_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "school_section_id", null: false
    t.integer "subject_id"
    t.index ["school_section_id"], name: "index_school_sections_users_on_school_section_id"
    t.index ["subject_id"], name: "index_school_sections_users_on_subject_id"
    t.index ["user_id"], name: "index_school_sections_users_on_user_id"
  end

  create_table "school_years", force: :cascade do |t|
    t.bigint "school_class_id", null: false
    t.date "start"
    t.date "end"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_class_id"], name: "index_school_years_on_school_class_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_class_id", null: false
    t.index ["school_class_id"], name: "index_subjects_on_school_class_id"
  end

  create_table "subjects_users", id: false, force: :cascade do |t|
    t.bigint "subject_id", null: false
    t.bigint "user_id", null: false
    t.index ["subject_id", "user_id"], name: "index_subjects_users_on_subject_id_and_user_id"
    t.index ["user_id", "subject_id"], name: "index_subjects_users_on_user_id_and_subject_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "role"
    t.bigint "school_section_id"
    t.string "jti"
    t.integer "subject_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["school_section_id"], name: "index_users_on_school_section_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "exams", "quarters"
  add_foreign_key "exams", "subjects"
  add_foreign_key "school_sections", "school_years"
  add_foreign_key "school_years", "school_classes"
  add_foreign_key "subjects", "school_classes"
  add_foreign_key "users", "school_sections"
end
