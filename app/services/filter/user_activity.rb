module Filter
  class UserActivity
    def self.call(options)
      options = options.keep_if { |_, val| val.present? }
      new(options).send(:filter)
    end

    private

    def initialize(options)
      @options = options
    end

    def filter
      fields = %w(id uid activity_type distance moving_time elapsed_time mile_pace city state_province country
                  start_date_local layoff raw_data route_id split_distance_coordinates)
      resource = ::UserActivity.select(fields)

      if @options[:city]
        resource = resource.where('city ilike ?', "#{@options[:city]}%")
      end

      if @options[:country]
        resource = resource.where('country ilike ?', "#{@options[:country]}%")
      end

      if @options[:distance_min] || @options[:distance_max]
        if @options[:distance_min]
          resource = resource.where('distance >= ?', @options[:distance_min])
        end
        if @options[:distance_max]
          resource = resource.where('distance <= ?', @options[:distance_max])
        end
      end

      if @options[:duration_min] || @options[:duration_max]
        if @options[:duration_min]
          resource = resource.where('moving_time >= ?', @options[:duration_min])
        end
        if @options[:duration_max]
          resource = resource.where('moving_time <= ?', @options[:duration_max])
        end
      end

      if @options[:layoff_min] || @options[:layoff_max]
        if @options[:layoff_min]
          resource = resource.where('layoff >= ?', @options[:layoff_min])
        end
        if @options[:layoff_max]
          resource = resource.where('layoff <= ?', @options[:layoff_max])
        end
      end

      if @options[:mile_pace]
        resource = resource.where('mile_pace <= ?', @options[:mile_pace])
      end

      resource.order(start_date_local: :desc)
    end
  end
end
