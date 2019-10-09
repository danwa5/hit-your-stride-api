class AddMilePaceToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :mile_pace, :integer
  end
end
