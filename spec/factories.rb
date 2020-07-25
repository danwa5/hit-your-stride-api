FactoryBot.define do
  factory :user_activity do
    activity_type { 'run' }
    uid { Faker::Number.number(digits: 6) }
    raw_data { {} }

    trait :processed do
      state { 'processed' }
    end
  end
end
