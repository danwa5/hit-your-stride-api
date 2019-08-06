class UserActivity < ApplicationRecord
  validates :activity_type, presence: true, inclusion: { in: %w(run) }
  validates :uid, presence: true, uniqueness: true, case_sensitive: false

  before_validation(on: :create) do
    self.activity_type = activity_type.downcase
  end

  state_machine :initial => :pending do
    event :processing do
      transition [:pending, :processing] => :processing
    end

    event :processed do
      transition :processing => :processed
    end

    event :failure do
      transition [:pending, :processing] => :failure
    end
  end
end
