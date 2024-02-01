# frozen_string_literal: true

module Ozon
  class Api < BaseApi
    # https://docs.ozon.ru/api/seller/#section/Chto-takoe-rabochaya-sreda
    URL = 'https://api-seller.ozon.ru'

    def initialize(mp_credential, options = {})
      super
      @api_key = mp_credential&.credentials&.[]('api_key')
      @client_id = mp_credential&.credentials&.[]('client_id')
    end

    private

    def headers
      super.merge(
        {
          'Api-Key' => @api_key,
          'Client-Id' => @client_id,
          'x-o3-app-name' => ENV.fetch('OZON_APP_ID')
        }
      )
    end

    def error_message(body)
      case response_content_type
      when :json
        "code: #{body[:code]}; #{body[:message]}"
      when :html
        body
      else
        ''
      end
    end
  end
end
