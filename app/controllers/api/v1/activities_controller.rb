module Api
  module V1
    class ActivitiesController < ApplicationController

      # GET /api/v1/activities
      def index
        fields = %w(id uid activity_type distance moving_time elapsed_time city state_province country start_date_local)
        activities = UserActivity.all.select(fields).order(:start_date_local)
        ja = activities.map{ |a| UserActivitySerializer.new(a) }

        render json: ja, status: :ok
      end
    end
  end
end
