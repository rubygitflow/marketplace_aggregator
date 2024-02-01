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
      credentials { { 'client_id' => '12345', 'api_key' => 'f89e2ac7d650' } }
    end

    trait :yandex do
      association :marketplace, :yandex
      association :client, :reserved
      instance_name { 'yandex@me.com' }
      credentials do
        { 'business_id' => '12345',
          'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87' }
      end
    end

    trait :dzen do
      association :marketplace, :dzen
      association :client, :reserved
      instance_name { 'dzen@me.com' }
      credentials { { 'client_id' => '12345', 'api_key' => '1234567890' } }
    end

    trait :wrong_ozon do
      association :marketplace, :ozon
      association :client, :reserved
      instance_name { 'ozon@me.com' }
      credentials { { 'client_id' => 'f89e2ac7d650', 'api_key' => '12345' } }
    end

    trait :wrong_yandex do
      association :marketplace, :yandex
      association :client, :reserved
      instance_name { 'yandex@me.com' }
      credentials do
        { 'business_id' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
          'token' => '12345' }
      end
    end

    trait :not_authentic_on_yandex do
      association :marketplace, :yandex
      association :client, :reserved
      credentials { nil }
    end

    trait :not_authentic_on_ozon do
      association :marketplace, :ozon
      association :client, :reserved
      credentials { nil }
    end
  end
end
