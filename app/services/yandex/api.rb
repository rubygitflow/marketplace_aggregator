# frozen_string_literal: true

module Yandex
  class Api
    URL = 'https://api.partner.market.yandex.ru'
    attr_accessor :connection

    def initialize(mp_credential, options = {})
      @connection = Connection.start
      @marketplace_credential = mp_credential
      @token = mp_credential&.credentials&.[]('token')
      @raise_an_error = false
    end

    def call(method:, raise_an_error: false, params: {}, body: {})
      # Let's define an HTTP method for a specific endpoint
      @raise_an_error = raise_an_error
      send(method, params, body)
    end

    private

    def url
      URL
    end

    def headers
      {
        'Authorization' => "OAuth oauth_token=\"#{@token}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
        'Content-Type' => 'application/json'
      }
    end

    def get(params = {}, _ = {})
      api_call do
        connection.get do |req|
          req.url url
          req.params = params
          req.headers = headers
        end
      end
    end

    def post(params = {}, body = {})
      api_call do
        connection.post do |req|
          req.url url
          req.params = params
          req.headers = headers
          req.body = body.to_json
        end
      end
    end

    def api_call
      response = yield
      body = begin
        JSON.parse response.body, symbolize_names: true
      rescue JSON::ParserError => e
        ErrorLogger.push e
        {}
      end
      if @raise_an_error && response.status >= 400
        raise_error(
          response.status,
          body[:errors]&.first&.[](:message),
          @marketplace_credential&.id
        )
      end

      [response.status, response.headers, body]
    end

    def raise_error(status, message, mp_credential_id)
      if status == 420
        raise MarketplaceAggregator::ApiLimitError.new(status, message, mp_credential_id)
      elsif [401, 403].include?(status)
        raise MarketplaceAggregator::ApiAccessDeniedError.new(status, message, mp_credential_id)
      elsif (400...500).include?(status)
        raise MarketplaceAggregator::ApiBadRequestError.new(status, message, mp_credential_id)
      elsif status >= 500
        raise MarketplaceAggregator::ApiError.new(status, message, mp_credential_id)
      end
    end
  end
end
