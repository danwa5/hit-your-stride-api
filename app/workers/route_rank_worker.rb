class RouteRankWorker
  include Sidekiq::Worker

  def perform(route_id)
    route = Route.find(route_id)
    activities = UserActivity.where(route: route).select(:id, :mile_pace).order(:mile_pace)

    return unless activities.to_a.count > 1

    # group all runs by the same mile pace
    runs = group_by_mile_pace(activities)

    offset = 1

    runs.sort.each_with_index do |(_, activity_ids), index|
      UserActivity.where(route: route, id: activity_ids).update_all(route_rank: index + offset)

      # when multiple runs are tied for the same ranking, then offset the next available rank
      offset += (activity_ids.count - 1) if activity_ids.count > 1
    end

    runs
  end

  private

  def group_by_mile_pace(activities)
    runs = {}

    activities.each do |activity|
      if runs.key?(activity.mile_pace)
        runs[activity.mile_pace] << activity.id
      else
        runs[activity.mile_pace] = [activity.id]
      end
    end

    runs
  end
end
