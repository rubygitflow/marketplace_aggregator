# frozen_string_literal: true

FactoryBot.define do
  factory :marketplace_credential do
    marketplace
    client
    instance_name { "#{Faker::Name.name}@me.com" }
    credentials { { 'client_id' => '12345', 'api_key' => '1234567890' } }

    trait :ozon do
      association :marketplace, :ozon
      association :client, :reserved
      instance_name { 'ozon@me.com' }
      credentials { { 'client_id' => '12345', 'api_key' => '1234567890' } }
    end

    trait :yandex do
      association :marketplace, :yandex
      association :client, :reserved
      instance_name { 'yandex@me.com' }
      credentials do
        { 'business_id' => '12345',
          'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVELBTR0anWh0lI8JMMIHWe87' }
      end
    end

    trait :not_authentic do
      credentials { nil }
    end
  end
end
