# frozen_string_literal: true

# Useful links:
# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductList
# https://curl.se/docs/manpage.html

module Ozon
  class CheckCredentials < BaseCheckCredentials
    # Because the HEAD method is not supported by the endpoint
    # https://api-seller.ozon.ru/v2/product/list
    # we use the curl command.
    # Ozon does not set restrictions on reading data using the REST API, but it works slowly

    private

    def bash_command
      <<~`BASH`
        curl -I \
        -H 'Api-Key: #{@mp_credential.credentials['api_key']}' \
        -H 'Client-Id: #{@mp_credential.credentials['client_id']}' \
        -H 'x-o3-app-name: #{ENV.fetch('OZON_APP_ID')}' \
        -X POST https://api-seller.ozon.ru/v2/product/list
      BASH
    end

    def http_client
      Ozon::Api::ProductList.new(@mp_credential)
    end
  end
end
