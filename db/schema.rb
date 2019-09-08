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

ActiveRecord::Schema.define(version: 2019_08_04_150412) do

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

  create_table "club_devices", force: :cascade do |t|
    t.string "number", default: ""
    t.date "date_of_issue"
    t.date "valid_to"
    t.string "call_sign", default: ""
    t.string "category", default: ""
    t.integer "transmitter_power"
    t.string "name_type_station", default: ""
    t.string "emission", default: ""
    t.string "input_frequency", default: ""
    t.string "output_frequency", default: ""
    t.string "enduser_name", default: ""
    t.string "enduser_city", default: ""
    t.string "enduser_street", default: ""
    t.string "enduser_house", default: ""
    t.string "enduser_number", default: ""
    t.string "applicant_name", default: ""
    t.string "applicant_city", default: ""
    t.string "applicant_street", default: ""
    t.string "applicant_house", default: ""
    t.string "applicant_number", default: ""
    t.string "station_city", default: ""
    t.string "station_street", default: ""
    t.string "station_house", default: ""
    t.string "station_number", default: ""
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_city"], name: "index_club_devices_on_applicant_city"
    t.index ["applicant_house"], name: "index_club_devices_on_applicant_house"
    t.index ["applicant_name"], name: "index_club_devices_on_applicant_name"
    t.index ["applicant_number"], name: "index_club_devices_on_applicant_number"
    t.index ["applicant_street"], name: "index_club_devices_on_applicant_street"
    t.index ["call_sign"], name: "index_club_devices_on_call_sign"
    t.index ["category"], name: "index_club_devices_on_category"
    t.index ["date_of_issue"], name: "index_club_devices_on_date_of_issue"
    t.index ["emission"], name: "index_club_devices_on_emission"
    t.index ["enduser_city"], name: "index_club_devices_on_enduser_city"
    t.index ["enduser_house"], name: "index_club_devices_on_enduser_house"
    t.index ["enduser_name"], name: "index_club_devices_on_enduser_name"
    t.index ["enduser_number"], name: "index_club_devices_on_enduser_number"
    t.index ["enduser_street"], name: "index_club_devices_on_enduser_street"
    t.index ["input_frequency"], name: "index_club_devices_on_input_frequency"
    t.index ["lat"], name: "index_club_devices_on_lat"
    t.index ["lng"], name: "index_club_devices_on_lng"
    t.index ["name_type_station"], name: "index_club_devices_on_name_type_station"
    t.index ["number"], name: "index_club_devices_on_number"
    t.index ["output_frequency"], name: "index_club_devices_on_output_frequency"
    t.index ["station_city"], name: "index_club_devices_on_station_city"
    t.index ["station_house"], name: "index_club_devices_on_station_house"
    t.index ["station_number"], name: "index_club_devices_on_station_number"
    t.index ["station_street"], name: "index_club_devices_on_station_street"
    t.index ["transmitter_power"], name: "index_club_devices_on_transmitter_power"
    t.index ["valid_to"], name: "index_club_devices_on_valid_to"
  end

  create_table "clubs", force: :cascade do |t|
    t.string "number", default: ""
    t.date "date_of_issue"
    t.date "valid_to"
    t.string "call_sign", default: ""
    t.string "category", default: ""
    t.integer "transmitter_power"
    t.string "enduser_name", default: ""
    t.string "enduser_city", default: ""
    t.string "enduser_street", default: ""
    t.string "enduser_house", default: ""
    t.string "enduser_number", default: ""
    t.string "applicant_name", default: ""
    t.string "applicant_city", default: ""
    t.string "applicant_street", default: ""
    t.string "applicant_house", default: ""
    t.string "applicant_number", default: ""
    t.string "station_city", default: ""
    t.string "station_street", default: ""
    t.string "station_house", default: ""
    t.string "station_number", default: ""
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["applicant_city"], name: "index_clubs_on_applicant_city"
    t.index ["applicant_house"], name: "index_clubs_on_applicant_house"
    t.index ["applicant_name"], name: "index_clubs_on_applicant_name"
    t.index ["applicant_number"], name: "index_clubs_on_applicant_number"
    t.index ["applicant_street"], name: "index_clubs_on_applicant_street"
    t.index ["call_sign"], name: "index_clubs_on_call_sign"
    t.index ["category"], name: "index_clubs_on_category"
    t.index ["date_of_issue"], name: "index_clubs_on_date_of_issue"
    t.index ["enduser_city"], name: "index_clubs_on_enduser_city"
    t.index ["enduser_house"], name: "index_clubs_on_enduser_house"
    t.index ["enduser_name"], name: "index_clubs_on_enduser_name"
    t.index ["enduser_number"], name: "index_clubs_on_enduser_number"
    t.index ["enduser_street"], name: "index_clubs_on_enduser_street"
    t.index ["lat"], name: "index_clubs_on_lat"
    t.index ["lng"], name: "index_clubs_on_lng"
    t.index ["number"], name: "index_clubs_on_number"
    t.index ["station_city"], name: "index_clubs_on_station_city"
    t.index ["station_house"], name: "index_clubs_on_station_house"
    t.index ["station_number"], name: "index_clubs_on_station_number"
    t.index ["station_street"], name: "index_clubs_on_station_street"
    t.index ["transmitter_power"], name: "index_clubs_on_transmitter_power"
    t.index ["valid_to"], name: "index_clubs_on_valid_to"
  end

  create_table "individual_devices", force: :cascade do |t|
    t.string "number", default: ""
    t.date "date_of_issue"
    t.date "valid_to"
    t.string "call_sign", default: ""
    t.string "category", default: ""
    t.integer "transmitter_power"
    t.string "name_type_station", default: ""
    t.string "emission", default: ""
    t.string "input_frequency", default: ""
    t.string "output_frequency", default: ""
    t.string "station_location", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_sign"], name: "index_individual_devices_on_call_sign"
    t.index ["category"], name: "index_individual_devices_on_category"
    t.index ["date_of_issue"], name: "index_individual_devices_on_date_of_issue"
    t.index ["emission"], name: "index_individual_devices_on_emission"
    t.index ["input_frequency"], name: "index_individual_devices_on_input_frequency"
    t.index ["name_type_station"], name: "index_individual_devices_on_name_type_station"
    t.index ["number"], name: "index_individual_devices_on_number"
    t.index ["output_frequency"], name: "index_individual_devices_on_output_frequency"
    t.index ["station_location"], name: "index_individual_devices_on_station_location"
    t.index ["transmitter_power"], name: "index_individual_devices_on_transmitter_power"
    t.index ["valid_to"], name: "index_individual_devices_on_valid_to"
  end

  create_table "individuals", force: :cascade do |t|
    t.string "number", default: ""
    t.date "date_of_issue"
    t.date "valid_to"
    t.string "call_sign", default: ""
    t.string "category", default: ""
    t.integer "transmitter_power"
    t.string "station_location", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["call_sign"], name: "index_individuals_on_call_sign"
    t.index ["category"], name: "index_individuals_on_category"
    t.index ["date_of_issue"], name: "index_individuals_on_date_of_issue"
    t.index ["number"], name: "index_individuals_on_number"
    t.index ["station_location"], name: "index_individuals_on_station_location"
    t.index ["transmitter_power"], name: "index_individuals_on_transmitter_power"
    t.index ["valid_to"], name: "index_individuals_on_valid_to"
  end

  create_table "proposals", force: :cascade do |t|
    t.uuid "multi_app_identifier", null: false
    t.integer "proposal_status_id", null: false
    t.string "category", limit: 1, null: false
    t.bigint "creator_id"
    t.string "name", limit: 160, default: "", null: false
    t.string "given_names", limit: 50, default: "", null: false
    t.string "pesel", limit: 11, default: ""
    t.date "birth_date"
    t.string "birth_place", limit: 50, default: ""
    t.string "phone", limit: 50, default: ""
    t.string "email", limit: 50, default: "", null: false
    t.string "address_city", limit: 50, default: "", null: false
    t.string "address_street", limit: 50, default: ""
    t.string "address_house", limit: 10, default: ""
    t.string "address_number", limit: 10, default: ""
    t.string "address_postal_code", limit: 10, default: ""
    t.string "c_address_city", limit: 50, default: ""
    t.string "c_address_street", limit: 50, default: ""
    t.string "c_address_house", limit: 10, default: ""
    t.string "c_address_number", limit: 10, default: ""
    t.string "c_address_postal_code", limit: 10, default: ""
    t.integer "esod_category"
    t.integer "exam_id"
    t.string "exam_fullname"
    t.date "exam_date_exam"
    t.integer "division_id"
    t.string "division_fullname"
    t.integer "division_min_years_old"
    t.integer "exam_fee_id"
    t.decimal "exam_fee_price", precision: 8, scale: 2, default: "0.0"
    t.boolean "confirm_that_the_data_is_correct", default: false
    t.text "bank_pdf_blob_path"
    t.text "face_image_blob_path"
    t.text "not_approved_comment", default: ""
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_proposals_on_category"
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
