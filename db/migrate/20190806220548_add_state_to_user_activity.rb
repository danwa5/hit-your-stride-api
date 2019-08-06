class AddStateToUserActivity < ActiveRecord::Migration[6.0]
  def change
    add_column :user_activities, :state, :string
  end
end
