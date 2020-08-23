FactoryBot.define do
  factory :user_activity do
    activity_type { 'run' }
    uid { Faker::Number.number(digits: 6) }

    trait :processed do
      state { 'processed' }
    end
  end

  factory :route do
    distance { Faker::Number.decimal(l_digits: 4, r_digits: 1) }
    start_latlng { "#{Faker::Number.decimal(l_digits: 2)},#{Faker::Number.decimal(l_digits: 2)}" }
    end_latlng { "#{Faker::Number.decimal(l_digits: 2)},#{Faker::Number.decimal(l_digits: 2)}" }
  end
end
