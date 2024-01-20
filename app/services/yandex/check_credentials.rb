# frozen_string_literal: true

# Useful links:
# https://yandex.ru/dev/market/partner-api/doc/ru/concepts/error-codes?ysclid=lr6jn1nebe634261603#405
# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings

module Yandex
  class CheckCredentials
    # Because the HEAD method is not supported by the endpoint
    # https://api.partner.market.yandex.ru/businesses/{businessId}/offer-mappings
    # we use the curl command.
    # The HEAD method allows us not to waste :x_ratelimit_resource_limit
    # curl command can invoke POST method with -I/--head option
    # https://curl.se/docs/manpage.html

    def call(mp_credential)
      curl = bash_command(mp_credential)

      case message = curl.split("\r\n").first
      when 'HTTP/1.1 200 OK'
        { ok: true }
      when %r{(HTTP/1.1 403 Forbidden)|(HTTP/2 403 )}
        # find out details from body of POST request
        status, _, body =
          Yandex::Api::OfferMappings.new(mp_credential)
                                    .call(raise_an_error: false, params: { limit: 1 })

        if status < 400
          { ok: true }
        else
          { errors: body[:errors]&.first&.[](:message) || 'something went wrong' }
        end
      else
        { errors: message }
      end
    end

    private

    def bash_command(mp_credential)
      <<~`BASH`
        curl -I \
        -H 'Authorization: OAuth oauth_token=#{mp_credential.credentials['token']}, \
        oauth_client_id=#{ENV.fetch('YANDEX_APP_ID')}' \
        -X POST https://api.partner.market.yandex.ru/businesses/\
        #{mp_credential.credentials['business_id']}/offer-mappings.json?limit=1
      BASH
    end
  end
end
