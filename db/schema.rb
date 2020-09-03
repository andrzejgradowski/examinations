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

ActiveRecord::Schema.define(version: 2020_08_18_110819) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.string "access_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_api_keys_on_name", unique: true
  end

  create_table "proposals", force: :cascade do |t|
    t.uuid "multi_app_identifier", null: false
    t.integer "proposal_status_id", null: false
    t.string "category", limit: 1, default: "", null: false
    t.bigint "creator_id"
    t.string "name", limit: 160, default: "", null: false
    t.string "given_names", limit: 50, default: "", null: false
    t.string "pesel", limit: 11, default: ""
    t.string "citizenship_code", default: "PL"
    t.date "birth_date"
    t.string "birth_place", limit: 50, default: ""
    t.string "family_name", limit: 50, default: ""
    t.string "phone", limit: 50, default: ""
    t.string "email", limit: 50, default: "", null: false
    t.boolean "lives_in_poland", default: true
    t.string "province_code", limit: 20, default: ""
    t.string "province_name", limit: 50, default: ""
    t.string "district_code", limit: 20, default: ""
    t.string "district_name", limit: 50, default: ""
    t.string "commune_code", limit: 20, default: ""
    t.string "commune_name", limit: 50, default: ""
    t.string "city_code", limit: 20, default: ""
    t.string "city_name", limit: 50, default: ""
    t.string "city_parent_code", limit: 20, default: ""
    t.string "city_parent_name", limit: 50, default: ""
    t.string "street_code", limit: 20, default: ""
    t.string "street_name", limit: 50, default: ""
    t.string "street_attribute", limit: 20, default: ""
    t.string "c_address_house", limit: 10, default: ""
    t.string "c_address_number", limit: 10, default: ""
    t.string "c_address_postal_code", limit: 10, default: ""
    t.integer "esod_category"
    t.integer "exam_id"
    t.string "exam_fullname"
    t.date "exam_date_exam"
    t.integer "division_id"
    t.string "division_fullname"
    t.string "division_short_name"
    t.integer "division_min_years_old"
    t.integer "exam_fee_id"
    t.decimal "exam_fee_price", precision: 8, scale: 2, default: "0.0"
    t.boolean "confirm_that_the_data_is_correct", default: false
    t.text "bank_pdf_blob_path"
    t.text "face_image_blob_path"
    t.text "consent_pdf_blob_path"
    t.text "not_approved_comment", default: ""
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "address_combine_id", limit: 26, default: ""
    t.index ["category"], name: "index_proposals_on_category"
    t.index ["creator_id", "division_id"], name: "index_proposals_on_creator_id_and_division_id"
    t.index ["creator_id"], name: "index_proposals_on_creator_id"
    t.index ["multi_app_identifier"], name: "index_proposals_on_multi_app_identifier"
    t.index ["pesel"], name: "index_proposals_on_pesel"
    t.index ["proposal_status_id"], name: "index_proposals_on_proposal_status_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "activities", default: [], array: true
    t.text "note", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id", "user_id"], name: "index_roles_users_on_role_id_and_user_id", unique: true
    t.index ["role_id"], name: "index_roles_users_on_role_id"
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true
    t.index ["user_id"], name: "index_roles_users_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "wso2is_userid"
    t.string "email", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "user_name"
    t.date "birth_date"
    t.string "birth_city"
    t.string "family_name"
    t.string "pesel"
    t.string "passport"
    t.string "phone"
    t.date "csu_confirmed_at"
    t.string "csu_confirmed_by"
    t.string "session_index"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "proposals", "users", column: "creator_id"
  add_foreign_key "roles_users", "roles"
  add_foreign_key "roles_users", "users"
end
