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
      fields = %w(id uid activity_type distance moving_time elapsed_time city state_province country start_date_local layoff)
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

      resource.order(start_date_local: :desc)
    end
  end
end
