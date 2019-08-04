class CreateUserActivities < ActiveRecord::Migration[6.0]
  def change
    create_table :user_activities do |t|
      t.string    :activity_type, null: false
      t.string    :uid, unique: true, null: false
      t.datetime  :start_date_utc
      t.datetime  :end_date_utc
      t.datetime  :start_date_local
      t.datetime  :end_date_local
      t.decimal   :distance, precision: 10, scale: 2
      t.integer   :moving_time
      t.integer   :elapsed_time
      t.string    :city
      t.string    :state_province
      t.string    :country
      t.json      :raw_data
      t.string    :checksum

      t.timestamps null: false
    end
  end
end
