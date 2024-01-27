# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoListV2

module Ozon
  class Api
    class ProductInfoList < Api
      def url
        "#{URL}/v2/product/info/list"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        super
      end
    end
  end
end
