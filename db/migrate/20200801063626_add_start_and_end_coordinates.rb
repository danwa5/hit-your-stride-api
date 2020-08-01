class AddStartAndEndCoordinates < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :start_latlng, :string
    add_column :user_activities, :end_latlng, :string
  end
end
