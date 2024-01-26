# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductList

module Ozon
  class Api
    class ProductList < Api
      def url
        "#{URL}/v2/product/list"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        super
      end
    end
  end
end
