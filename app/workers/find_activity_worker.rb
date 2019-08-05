class FindActivityWorker
  include Sidekiq::Worker

  def perform(date = nil)
    @date = date

    res = Api::Strava.get_activities_list(options)

    raise "#{res.code}: #{res.to_s}" unless res.success?

    activities = res.parsed_response

    found = activities.map do |a|
      type = a.fetch('type')
      uid  = a.fetch('id')
      { 'type' => type.downcase, 'uid' => uid } if type =~ /run/i
    end.compact

    found.each do |r|
      UserActivity.where(activity_type: r['type'], uid: r['uid']).first_or_create!
    end

    found
  end

  private

  def options
    d ||= begin
      @date.present? ? Date.parse(@date) : 1.week.ago
    rescue
      1.week.ago
    end

    { date: d.strftime('%Y-%m-%d') }
  end
end
