module Types
  class RunType < Types::BaseObject
    field :start_date_local, String, null: false
    field :moving_time, Integer, null: true
    field :distance, Float, null: true
    field :mile_pace, Integer, null: true
    field :route_rank, Integer, null: true
  end
end
