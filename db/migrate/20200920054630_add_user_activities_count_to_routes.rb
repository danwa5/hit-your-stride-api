class AddUserActivitiesCountToRoutes < ActiveRecord::Migration[6.0]
  def change
    add_column :routes, :user_activities_count, :integer
  end
end
