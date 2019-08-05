class UserActivity < ApplicationRecord
  validates :activity_type, presence: true, inclusion: { in: %w(run) }
  validates :uid, presence: true, uniqueness: true, case_sensitive: false

  before_validation(on: :create) do
    self.activity_type = activity_type.downcase
  end
end
