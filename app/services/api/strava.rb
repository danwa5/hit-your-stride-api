class Api::Strava
  include HTTParty

  base_uri 'https://www.strava.com/api'

  format :json

  class << self
    def get_profile
      new.get_profile
    end

    def get_activities_list(options = {})
      if options[:date].present?
        options[:epoch] = DateTime.parse("#{options[:date]} 00:00:00 PST").to_i
      else
        options[:epoch] = 1.week.ago.to_i
      end
      new(options).get_activities_list
    end

    def get_activity(options = {})
      new(options).get_activity
    end
  end

  def initialize(options = {})
    @client_token = ENV['STRAVA_ACCESS_TOKEN']
    @options      = options
  end

  # GET https://www.strava.com/api/v3/athlete
  def get_profile
    self.class.get("/v3/athlete", headers: headers)
  end

  # GET https://www.strava.com/api/v3/athlete/activities
  def get_activities_list
    self.class.get("/v3/athlete/activities", query: { after: @options[:epoch] }, headers: headers)
  end

  # GET https://www.strava.com/api/v3/activities/:id
  def get_activity
    self.class.get("/v3/activities/#{@options[:uid]}", headers: headers)
  end

  private

  def headers
    {
      'Authorization' => "Bearer #{@client_token}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  end

end
