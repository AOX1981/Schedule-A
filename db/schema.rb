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

ActiveRecord::Schema[8.1].define(version: 2026_02_22_013814) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "account_type", default: "credit_card"
    t.datetime "created_at", null: false
    t.string "last4", limit: 4, null: false
    t.string "nickname", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "last4"], name: "index_accounts_on_user_id_and_last4"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.datetime "revoked_at"
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "audit_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action", null: false
    t.uuid "auditable_id", null: false
    t.string "auditable_type", null: false
    t.jsonb "changed_fields", default: {}
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "business_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "business_name", null: false
    t.string "business_type", default: "sole_proprietorship"
    t.datetime "created_at", null: false
    t.string "ein"
    t.integer "tax_year", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id", "tax_year"], name: "index_business_profiles_on_user_id_and_tax_year", unique: true
    t.index ["user_id"], name: "index_business_profiles_on_user_id"
  end

  create_table "expense_lines", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.decimal "cost", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "item", null: false
    t.integer "line_number", null: false
    t.uuid "receipt_id", null: false
    t.string "tax_category"
    t.string "transaction_display_id", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.decimal "writeoff_percent", precision: 5, scale: 2, default: "100.0"
    t.decimal "writeoff_value", precision: 10, scale: 2
    t.index ["receipt_id", "line_number"], name: "index_expense_lines_on_receipt_id_and_line_number", unique: true
    t.index ["receipt_id"], name: "index_expense_lines_on_receipt_id"
    t.index ["tax_category"], name: "index_expense_lines_on_tax_category"
    t.index ["transaction_display_id"], name: "index_expense_lines_on_transaction_display_id", unique: true
    t.index ["user_id"], name: "index_expense_lines_on_user_id"
  end

  create_table "receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "account_id"
    t.uuid "business_profile_id"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "designation", default: "business", null: false
    t.jsonb "extracted_data", default: {}
    t.text "raw_ocr_text"
    t.integer "receipt_number", null: false
    t.string "source", default: "upload", null: false
    t.string "state"
    t.string "status", default: "pending", null: false
    t.string "store_name"
    t.decimal "total_amount", precision: 10, scale: 2
    t.date "transaction_date"
    t.string "transaction_time"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["account_id"], name: "index_receipts_on_account_id"
    t.index ["business_profile_id"], name: "index_receipts_on_business_profile_id"
    t.index ["designation"], name: "index_receipts_on_designation"
    t.index ["status"], name: "index_receipts_on_status"
    t.index ["user_id", "receipt_number"], name: "index_receipts_on_user_id_and_receipt_number", unique: true
    t.index ["user_id"], name: "index_receipts_on_user_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "full_name", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "audit_logs", "users"
  add_foreign_key "business_profiles", "users"
  add_foreign_key "expense_lines", "receipts"
  add_foreign_key "expense_lines", "users"
  add_foreign_key "receipts", "accounts"
  add_foreign_key "receipts", "business_profiles"
  add_foreign_key "receipts", "users"
end
