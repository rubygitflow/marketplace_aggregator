# frozen_string_literal: true

# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings

module Yandex
  class Api
    class OfferMappings < Api
      MAX_REQUESTS_PER_MINUTE = 600
      RATE_LIMIT_DURATION = 60

      include Yandex::Sleeper

      def initialize(mp_credential, options = {})
        super
        @business_id = mp_credential&.credentials&.[]('business_id')
      end

      def url
        "#{URL}/businesses/#{@business_id}/offer-mappings.json"
      end

      def call(method: :post, raise_an_error: true, params: {}, body: {})
        response = super
        delay_if_limits(response[1]) if response[0] == 200
        response
      end

      private

      # INPUT:
      # headers = {
      #   X-RateLimit-Resource-Remaining: 600
      # }
      def delay_if_limits(headers)
        if headers.fetch(
          'X-RateLimit-Resource-Remaining',
          MAX_REQUESTS_PER_MINUTE
        ).to_i < limiting_remaining_requests
          do_sleep(headers, RATE_LIMIT_DURATION)
        end
      end
    end
  end
end
