class AddSplitDistanceCoordinatesToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :split_distance_coordinates, :json
  end
end
