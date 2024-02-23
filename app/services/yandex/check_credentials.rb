# frozen_string_literal: true

# Useful links:
# https://yandex.ru/dev/market/partner-api/doc/ru/concepts/error-codes
# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings
# https://curl.se/docs/manpage.html

module Yandex
  class CheckCredentials < BaseCheckCredentials
    # Because the HEAD method is not supported by the endpoint
    # https://api.partner.market.yandex.ru/businesses/{businessId}/offer-mappings
    # we use the curl command.
    # The HEAD method allows us not to waste :x_ratelimit_resource_limit

    private

    def bash_command
      <<~`BASH`
        curl -I \
        -H 'Authorization: OAuth oauth_token=#{@mp_credential.credentials['token']}, \
        oauth_client_id=#{ENV.fetch('YANDEX_APP_ID')}' \
        -X POST https://api.partner.market.yandex.ru/businesses/\
        #{@mp_credential.credentials['business_id']}/offer-mappings.json?limit=1
      BASH
    end

    def http_client
      Yandex::Api::OfferMappings.new(@mp_credential)
    end

    def http_client_call
      @http_client.call(params: { limit: 1 })
    end
  end
end
