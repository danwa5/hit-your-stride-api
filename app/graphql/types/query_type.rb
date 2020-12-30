module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :fastest_runs_for_route, resolver: Queries::FastestRunsForRoute
  end
end
