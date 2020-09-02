class UserActivitySerializer
  include FastJsonapi::ObjectSerializer

  attributes :uid, :activity_type, :distance, :moving_time, :elapsed_time, :mile_pace,
             :city, :state_province, :country, :layoff, :route_id, :route_rank

  attribute :start_date do |object|
    object.start_date_local
  end

  attribute :polyline do |object|
    object.raw_data&.fetch('map', {})&.fetch('summary_polyline', nil)
  end

  attribute :split_distance_coordinates do |object|
    object.split_distance_coordinates&.fetch('coordinates', nil)
  end
end
