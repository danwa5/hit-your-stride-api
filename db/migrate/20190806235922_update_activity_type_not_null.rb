class UpdateActivityTypeNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :user_activities, :activity_type, true
  end
end
