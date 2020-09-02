class AddRouteRankToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :route_rank, :integer
  end
end
