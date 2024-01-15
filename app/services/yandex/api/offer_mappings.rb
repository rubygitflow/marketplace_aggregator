# frozen_string_literal: true

# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings

module Yandex
  class Api
    class OfferMappings < Api
      def initialize(mp_credential, options = {})
        super
        @business_id = mp_credential&.credentials&.[]('business_id')
      end

      def url
        "#{URL}/businesses/#{@business_id}/offer-mappings.json"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        super
      end
    end
  end
end
