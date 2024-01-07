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

ActiveRecord::Schema[7.1].define(version: 2024_01_06_161532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "hstore"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "product_scrub_status", ["unspecified", "success", "gone"]
  create_enum "product_status", ["preliminary", "on_moderation", "failed_moderation", "published", "unpublished", "archived"]

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "marketplace_credentials", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.string "instance_name", comment: "user login to the marketplace"
    t.bigint "marketplace_id", null: false
    t.hstore "credentials"
    t.boolean "is_valid", default: true, comment: "result of checking marketplace credentials"
    t.datetime "last_sync_at_products", comment: "date and time of last synchronization with the marketplace"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_marketplace_credentials_on_client_id"
    t.index ["marketplace_id"], name: "index_marketplace_credentials_on_marketplace_id"
  end

  create_table "marketplaces", force: :cascade do |t|
    t.string "logo", comment: "link to image"
    t.string "name"
    t.string "label"
    t.hstore "credential_attributes", comment: "list of oAuth attributes"
    t.string "product_url", comment: "Url to product on the marketplace by Id"
    t.string "product_url_attr", comment: "type of Id in product Url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

# Could not dump table "products" because of following StandardError
#   Unknown type 'monetary_amount' for column 'price'

  add_foreign_key "marketplace_credentials", "clients"
  add_foreign_key "marketplace_credentials", "marketplaces"
  add_foreign_key "products", "marketplace_credentials"
end
