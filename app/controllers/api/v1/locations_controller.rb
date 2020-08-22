module Api
  module V1
    class LocationsController < ApplicationController
      # GET /api/v1/locations
      #
      # NOTE: Is there a better way to return a non-resource response?
      def index
        locations = UserActivity.select(:city, :state_province, :country).distinct.order(:city)
        serializer = LocationSerializer.new(locations).serializable_hash

        render json: { results: serializer[:data] }
      end
    end
  end
end
