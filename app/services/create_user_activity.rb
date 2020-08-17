require 'state_codes'

class CreateUserActivity
  include StateCodes
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
            # try updating from existing data if data is not passed in as argument
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
      mile_pace: mile_pace,
      moving_time: moving_time,
      state_province: state_province,
      start_date_utc: start_date_utc,
      start_date_local: start_date_local,
      start_latlng: start_latlng,
      end_latlng: end_latlng,
      raw_data: raw_data
    }
  end

  def activity_type
    raw_data.fetch('type', '').downcase
  end

  # @type [Decimal] - meters
  def distance
    raw_data.fetch('distance', nil)
  end

  # @type [Integer] - seconds / mile
  def mile_pace
    min_per_mile = moving_time / (distance * 60 * 0.00062137)
    whole_minutes = min_per_mile.floor
    fractional_minutes = min_per_mile - whole_minutes
    seconds = (60 * fractional_minutes).round
    (whole_minutes * 60) + seconds
  end

  # @type [Integer] - seconds
  def moving_time
    raw_data.fetch('moving_time', nil)
  end

  # @type [Integer] - seconds
  def elapsed_time
    raw_data.fetch('elapsed_time', nil)
  end

  def start_date_utc
    raw_data.fetch('start_date', nil)
  end

  def start_date_local
    raw_data.fetch('start_date_local', nil)
  end

  def start_latlng
    "#{start_latitude},#{start_longitude}"
  end

  # take the coordinate with the greater precision
  def start_latitude
    api_start_lat = raw_data.fetch('start_latlng', []).first
    pl_start_lat = polyline_coordinates.first.first

    coordinate_precision(pl_start_lat) > coordinate_precision(api_start_lat) ? pl_start_lat : api_start_lat
  end

  # take the coordinate with the greater precision
  def start_longitude
    api_start_lng = raw_data.fetch('start_latlng', []).last
    pl_start_lng = polyline_coordinates.first.last

    coordinate_precision(pl_start_lng) > coordinate_precision(api_start_lng) ? pl_start_lng : api_start_lng
  end

  def end_latlng
    "#{end_latitude},#{end_longitude}"
  end

  # take the coordinate with the greater precision
  def end_latitude
    api_end_lat = raw_data.fetch('end_latlng', []).first
    pl_end_lat = polyline_coordinates.last.first

    coordinate_precision(pl_end_lat) > coordinate_precision(api_end_lat) ? pl_end_lat : api_end_lat
  end

  # take the coordinate with the greater precision
  def end_longitude
    api_end_lng = raw_data.fetch('end_latlng', []).last
    pl_end_lng = polyline_coordinates.last.last

    coordinate_precision(pl_end_lng) > coordinate_precision(api_end_lng) ? pl_end_lng : api_end_lng
  end

  def coordinate_precision(coordinate)
    return 0 unless coordinate.present?
    String(coordinate).split('.').last.size
  end

  def polyline_coordinates
    @polyline_coordinates ||= begin
      polyline = raw_data.fetch('map', {}).fetch('summary_polyline', nil)
      FastPolylines.decode(polyline)
    end
  end

  # geolocation-related
  def location
    @location ||= begin
      return {} unless start_latlng.present?

      g = Geocoder.search(start_latlng).first
      g.data['address']
    rescue
      {}
    end
  end

  def city
    location.fetch('city', nil) || location.fetch('town', nil) || location.fetch('village', nil)
  end

  def state_province
    state = location.fetch('state', nil)
    return state if state.to_s.length == 2

    state_codes.fetch(state, state)
  end

  def country
    h = {
      'United States of America' => 'United States',
      'USA' => 'United States'
    }

    country = location.fetch('country', nil)

    h.fetch(country, country)
  end
end
