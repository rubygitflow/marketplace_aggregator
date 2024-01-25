# frozen_string_literal: true

class BaseApi
  URL = '#marketplace_api_http_domen_name'

  attr_accessor :connection
  attr_reader :response_content_type

  def initialize(mp_credential, options = {})
    @connection = Connection.start
    @marketplace_credential = mp_credential
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
    @response_content_type = content_type(response.headers)
    body = response_parse(response.body)
    raise_error(
      response.status,
      error_message(body)
    )

    [response.status, response.headers, body]
  end

  def error_message(body)
    raise NotImplementedError, "#{self.class}: #{I18n.t('errors.marketplace_has_not_been_selected')}"
  end

  def raise_error(status, message)
    return unless @raise_an_error
    return if status < 400

    if status == 420
      raise MarketplaceAggregator::ApiLimitError.new(status, message, @marketplace_credential.id)
    elsif [401, 403].include?(status)
      raise MarketplaceAggregator::ApiAccessDeniedError.new(status, message, @marketplace_credential.id)
    elsif (400...500).include?(status)
      raise MarketplaceAggregator::ApiBadRequestError.new(status, message, @marketplace_credential.id)
    elsif status >= 500
      raise MarketplaceAggregator::ApiError.new(status, message, @marketplace_credential.id)
    end
  end

  def content_type(headers)
    case headers.[]('content-type')
    when %r{application/json}
      :json
    when %r{text/html}
      :html
    else
      :any
    end
  end

  def response_parse(body)
    if response_content_type == :json
      begin
        JSON.parse body, symbolize_names: true
      rescue JSON::ParserError => e
        ErrorLogger.push e
        {}
      end
    else
      body
    end
  end
end
