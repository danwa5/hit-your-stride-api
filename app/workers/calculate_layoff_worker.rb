class CalculateLayoffWorker
  include Sidekiq::Worker

  def perform
    activities = UserActivity.order(:start_date_local).pluck(:id, :start_date_local, :layoff)

    return false unless activities.any?

    prev_run_date = nil

    activities.each do |a|
      run_id   = a[0].to_i
      run_date = a[1].to_date
      layoff   = a[2]

      if prev_run_date.present?
        days = (run_date - prev_run_date).to_i

        # do not update layoff if value is the same
        if days != layoff
          UserActivity.where(id: run_id).update_all(layoff: days)
        end
      end

      prev_run_date = run_date
    end
  end
end
