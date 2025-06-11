FactoryBot.define do
  factory :spectrum do
    sequence(:name) { |n| "Spectrum #{n}" }
    description { Faker::Lorem.paragraph }
    min_value { -10000 }
    max_value { 10000 }
    step { 100 }
    active { true }

    trait :inactive do
      active { false }
    end

    trait :with_custom_range do
      min_value { -5000 }
      max_value { 5000 }
      step { 50 }
    end
  end
end
