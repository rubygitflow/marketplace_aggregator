# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/CategoryAPI_GetCategoryTree

module Ozon
  class Api
    class DescriptionCategoryTree < Api
      def url
        "#{URL}/v1/description-category/tree"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        super
      end
    end
  end
end
