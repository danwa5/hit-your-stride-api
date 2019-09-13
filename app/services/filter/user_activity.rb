module Filter
  class UserActivity
    def self.call(options)
      new(options).filter
    end

    def initialize(options)
      @options = options
    end

    def filter
      fields = %w(id uid activity_type distance moving_time elapsed_time city state_province country start_date_local layoff)
      resource = ::UserActivity.select(fields)

      if @options[:city]
        resource = resource.where('city ilike ?', @options[:city])
      end

      if @options[:country]
        resource = resource.where('country ilike ?', @options[:country])
      end

      resource.order(start_date_local: :desc)
    end
  end
end
