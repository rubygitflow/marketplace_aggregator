# frozen_string_literal: true

FactoryBot.define do
  factory :client do
    deleted_at { nil }

    trait :reserved do
      id { '0856b4f9-eb4e-4602-8c06-8539d029a3bd' }
    end
  end
end
