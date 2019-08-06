class UserActivitySerializer
  include FastJsonapi::ObjectSerializer
  attributes :uid, :activity_type, :distance, :moving_time, :elapsed_time, :city, :state_province, :country

  attribute :start_date do |object|
    object.start_date_local
  end
end
