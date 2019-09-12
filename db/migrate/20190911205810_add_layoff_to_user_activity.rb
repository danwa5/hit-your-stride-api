class AddLayoffToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :layoff, :integer
    add_index :user_activities, :start_date_local
  end
end
