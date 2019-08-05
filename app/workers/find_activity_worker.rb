class FindActivityWorker
  include Sidekiq::Worker

  def perform(date = nil)
    @date = date

    res = Api::Strava.get_activities_list(options)

    raise "#{res.code}: #{res.to_s}" unless res.success?

    activities = res.parsed_response

    created = []

    activities.each do |a|
      type = a.fetch('type')
      uid  = a.fetch('id')

      next unless type =~ /run/i

      res = CreateUserActivity.call(uid: uid, raw_data: a)
      activity = res.value!
      created << activity.uid
    end

    created
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
