# frozen_string_literal: true

module Yandex
  class Api
    URL = 'https://api.partner.market.yandex.ru'
    attr_accessor :connection

    def initialize(mp_credential, options = {})
      @connection = Connection.start
      @marketplace_credential = mp_credential
      @token = mp_credential&.credentials&.[]('token')
    end

    def call(method:, params: {}, body: {})
      # Let's define an HTTP method for a specific endpoint
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
      body = JSON.parse response.body, symbolize_names: true
      [response.status, response.headers, body]
    end
  end
end
