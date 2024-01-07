# frozen_string_literal: true

FactoryBot.define do
  sequence(:name) { |n| "Product#{n}" }

  factory :product do
    marketplace_credential
    name

    trait :yandex do
      association :marketplace_credential, :yandex
    end

    trait :ozon do
      association :marketplace_credential, :ozon
    end
  end
end
