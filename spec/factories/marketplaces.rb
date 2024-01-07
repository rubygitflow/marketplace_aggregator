# frozen_string_literal: true

FactoryBot.define do
  factory :marketplace do
    name { 'Ozon' }
    label { 'Ozon' }
    product_url { 'https://www.ozon.ru/context/detail/id/@attr' }
    product_url_attr { 'sku' }

    trait :ozon do
      name { 'Ozon' }
      label { 'Ozon' }
      product_url { 'https://www.ozon.ru/context/detail/id/@attr' }
      product_url_attr { 'sku' }
    end

    trait :yandex do
      name { 'Yandex' }
      label { 'Яндекс.Маркет' }
      product_url { 'https://pokupki.market.yandex.ru/product/@attr' }
      product_url_attr { 'sku' }
    end

    trait :dzen do
      name { 'Dzen' }
      label { 'Dzen' }
    end

    trait :new do
      name { 'TON' }
      label { 'TON' }
    end
  end
end
