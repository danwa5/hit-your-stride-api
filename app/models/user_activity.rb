class UserActivity < ApplicationRecord
  validates :activity_type, inclusion: { in: %w(run), if: proc { |o| o.activity_type.present? } }
  validates :uid, presence: true, uniqueness: true, case_sensitive: false

  belongs_to :route, optional: true

  state_machine :initial => :pending do
    event :processing do
      transition [:pending, :processing, :failure] => :processing
    end

    event :processed do
      transition :processing => :processed
    end

    event :failure do
      transition [:pending, :processing] => :failure
    end
  end

  def polyline
    raw_data&.fetch('map', {})&.fetch('summary_polyline', nil)
  end
end
