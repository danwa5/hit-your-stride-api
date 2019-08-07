class CreateUserActivity
  include Services::BaseService
  extend Dry::Initializer

  option :uid
  option :raw_data

  def call
    Try() do
      activity = nil

      ActiveRecord::Base.transaction do
        activity = UserActivity.where(uid: uid).first_or_initialize

        unless activity.processed?
          begin
            # Try updating from existing data if data is not passed in as argument
            @raw_data = activity.raw_data if @raw_data.blank? && activity.persisted?

            activity.processing!
            activity.update!(activity_attrs)
            activity.processed!
          rescue
            activity.failure!
          end
        end
      end

      activity
    end
  end

  private

  def activity_attrs
    {
      activity_type: activity_type,
      city: city,
      country: country,
      distance: distance,
      elapsed_time: elapsed_time,
      moving_time: moving_time,
      state_province: state_province,
      start_date_utc: start_date_utc,
      start_date_local: start_date_local,
      raw_data: raw_data
    }
  end

  def activity_type
    raw_data.fetch('type', '').downcase
  end

  def distance
    raw_data.fetch('distance', nil)
  end

  def moving_time
    raw_data.fetch('moving_time', nil)
  end

  def elapsed_time
    raw_data.fetch('elapsed_time', nil)
  end

  def city
    raw_data.fetch('location_city', nil)
  end

  def state_province
    raw_data.fetch('location_state', nil)
  end

  def country
    raw_data.fetch('location_country', nil)
  end

  def start_date_utc
    raw_data.fetch('start_date', nil)
  end

  def start_date_local
    raw_data.fetch('start_date_local', nil)
  end
end