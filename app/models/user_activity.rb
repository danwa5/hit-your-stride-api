class UserActivity < ApplicationRecord
  validates :activity_type, presence: true, inclusion: { in: %w(run) }
  validates :uid, presence: true, uniqueness: true, case_sensitive: false
end
