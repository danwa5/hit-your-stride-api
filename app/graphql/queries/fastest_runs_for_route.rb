module Queries
  class FastestRunsForRoute < Queries::BaseQuery
    type [Types::RunType], null: false
    argument :route_id, ID, required: true

    def resolve(route_id:)
      UserActivity.where(route_id: route_id).order(:route_rank).limit(5)
    rescue ActiveRecord::RecordNotFound => e
      GraphQL::ExecutionError.new('Route does not exist.')
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid attributes for #{e.record.class}:" \
        " #{e.record.errors.full_messages.join(', ')}")
    end
  end
end
