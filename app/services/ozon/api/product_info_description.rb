# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoDescription

module Ozon
  class Api
    class ProductInfoDescription < Api
      def url
        "#{URL}/v1/product/info/description"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        super
      end
    end
  end
end
