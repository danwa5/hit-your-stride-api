# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_08_06_220548) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "user_activities", force: :cascade do |t|
    t.string "activity_type", null: false
    t.string "uid", null: false
    t.datetime "start_date_utc"
    t.datetime "end_date_utc"
    t.datetime "start_date_local"
    t.datetime "end_date_local"
    t.decimal "distance", precision: 10, scale: 2
    t.integer "moving_time"
    t.integer "elapsed_time"
    t.string "city"
    t.string "state_province"
    t.string "country"
    t.json "raw_data"
    t.string "checksum"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
  end

end
