module Api
  module V1
    class ActivitiesController < ApplicationController

      # GET /api/v1/activities
      def index
        activities = Filter::UserActivity.call(search_params)
        pagy, records = pagy(activities, page: page_param)
        serializer = UserActivitySerializer.new(records).serializable_hash

        render json: { results: serializer[:data], pagy: pagy_metadata(pagy) }, status: :ok
      end

      private

      def search_params
        params.permit(:page, :city, :country)
      end

      def page_param
        p = params[:page].to_i
        p >= 1 ? p : 1
      end
    end
  end
end
