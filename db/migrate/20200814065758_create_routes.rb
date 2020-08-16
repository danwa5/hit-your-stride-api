class CreateRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :routes do |t|
      t.string  :name
      t.integer :distance, null: false
      t.string  :start_latlng, null: false
      t.string  :end_latlng, null: false
      t.string  :city
      t.string  :state_province
      t.string  :country

      t.timestamps null: false
    end

    add_column :user_activities, :route_id, :integer
  end
end
