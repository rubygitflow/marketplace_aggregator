# frozen_string_literal: true

module Yandex
  class Api < BaseApi
    URL = 'https://api.partner.market.yandex.ru'

    def initialize(mp_credential, options = {})
      super
      @token = mp_credential&.credentials&.[]('token')
    end

    private

    def headers
      super.merge(
        {
          'Authorization' => "OAuth oauth_token=\"#{@token}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\""
        }
      )
    end

    def error_message(body)
      case response_content_type
      when :json
        body[:errors]&.first&.[](:message)
      when :html
        body
      else
        ''
      end
    end
  end
end
