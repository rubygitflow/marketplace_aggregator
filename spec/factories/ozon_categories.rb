# frozen_string_literal: true

FactoryBot.define do
  factory :ozon_category do
    category_name { 'MyCategory' }
    description_category_id { 1 }
    type_name { 'MyType' }
    type_id { 2 }
  end
end
