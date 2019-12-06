module Api
  module V1
    class ActivitiesController < ApplicationController
      before_action :transform_keys, only: [:index]

      # GET /api/v1/activities
      def index
        activities = Filter::UserActivity.call(search_params)
        pagy, records = pagy(activities, page: page_param, items: 10)
        serializer = UserActivitySerializer.new(records).serializable_hash

        render json: { results: serializer[:data], pagy: pagy_metadata(pagy) }, status: :ok
      rescue Exception => e
        render json: { errors: [ { title: e.class.to_s, code: '400', detail: e.message } ] }, status: :bad_request
      end

      private

      def transform_keys
        params.transform_keys! { |key| key.tr('-', '_') }
      end

      def search_params
        params.permit(:page, :city, :country, :distance_min, :distance_max, :duration_min, :duration_max,
                      :layoff_min, :layoff_max, :mile_pace)
      end

      def page_param
        p = search_params[:page].to_i
        p >= 1 ? p : 1
      end
    end
  end
end
