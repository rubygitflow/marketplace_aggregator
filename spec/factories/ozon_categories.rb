# frozen_string_literal: true

FactoryBot.define do
  factory :ozon_category do
    category_name { 'MyCategory' }
    description_category_id { 1 }
    type_name { 'MyType' }
    type_id { 2 }

    trait :с_15621048_91258 do
      category_name { 'Обувь/Повседневная обувь' }
      description_category_id { 15621048 }
      type_name { 'Полусапоги' }
      type_id { 91258 }
    end

    trait :с_15621032_0 do
      category_name { 'Обувь' }
      description_category_id { 15621032 }
      type_name { nil }
      type_id { 0 }
    end
  end
end
