class SplitDistanceCoordinatesWorker
  include Sidekiq::Worker

  # returns an array of mile marker coordinates
  #
  # {
  #   "coordinates" => [
  #     {"distance"=>0.9868107106240194, "latlng"=>[37.71292, -121.91014]},
  #     {"distance"=>1.9930428393408368, "latlng"=>[37.72734, -121.90997]},
  #     {"distance"=>3.0065555459318345, "latlng"=>[37.74133, -121.91413]},
  #   ]
  # }
  def perform(uid)
    activity = UserActivity.find_by(uid: uid)
    return unless activity.present?

    coordinates = FastPolylines.decode(activity.polyline)

    data = cumulative_distance_data(coordinates)
    total_distance = data.last.fetch('cumulative_distance')

    distance_values = data.map { |h| h['cumulative_distance'] }
    mile_markers = { 'coordinates' => [] }

    for i in (1..(total_distance.floor)) do
      # get the distance closest to each mile marker
      val = distance_values.min_by { |v| (i-v).abs }

      # get the full data point containing the mile marker
      dp = data.select { |h| h['cumulative_distance'] == val }.first

      mile_markers['coordinates'] << {
        'distance' => val,
        'latlng' => dp['point2']
      }
    end

    activity.update!(split_distance_coordinates: mile_markers)

    IdentifyRouteWorker.perform_async(activity.uid)

    mile_markers
  end

  private

  def cumulative_distance_data(coordinates)
    data = [];
    distance = 0;

    for i in 0..(coordinates.length - 2) do
      point1 = coordinates[i]
      point2 = coordinates[i+1]
      distance += Geocoder::Calculations.distance_between(point1, point2, { units: :mi })

      data << {
        'point1' => point1,
        'point2' => point2,
        'cumulative_distance' => distance
      }
    end

    data
  end
end
