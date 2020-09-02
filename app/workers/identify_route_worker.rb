class IdentifyRouteWorker
  include Sidekiq::Worker

  def perform(uid)
    activity = UserActivity.find_by(uid: uid)
    return unless activity.present?

    routes = Route.where(distance: (activity.distance-200)..(activity.distance+200))

    if routes.any?
      route_matched = false

      routes.each do |route|
        if within_proximity?(activity.start_latlng, route.start_latlng) && within_proximity?(activity.end_latlng, route.end_latlng)
          activity.update!(route: route)
          route_matched = true
          RouteRankWorker.perform_async(route.id)
          break
        end
      end

      create_route(activity) unless route_matched
    else
      create_route(activity)
    end
  end

  private

  def within_proximity?(run_coordinate, route_coordinate)
    distance = Geocoder::Calculations.distance_between(run_coordinate.split(','), route_coordinate.split(','), { units: :km })
    distance.round(1) <= 0.3
  end

  def create_route(activity)
    route = Route.create!(
      distance: activity.distance.round(-1),
      start_latlng: activity.start_latlng,
      end_latlng: activity.end_latlng,
      city: activity.city,
      state_province: activity.state_province,
      country: activity.country
    )

    activity.update!(route: route)
  end
end
