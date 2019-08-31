module Api
  module V1
    class ActivitiesController < ApplicationController

      # GET /api/v1/activities
      def index
        fields = %w(id uid activity_type distance moving_time elapsed_time city state_province country start_date_local)
        activities = UserActivity.all.select(fields).order('start_date_local DESC')

        pagy, records = pagy(activities, page: page_param)
        serializer = UserActivitySerializer.new(records).serializable_hash

        render json: { results: serializer[:data], pagy: pagy_metadata(pagy) }, status: :ok
      end

      private

      def page_param
        p = params[:page].to_i
        p >= 1 ? p : 1
      end
    end
  end
end
