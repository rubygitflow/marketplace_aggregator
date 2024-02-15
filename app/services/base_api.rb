# frozen_string_literal: true

class BaseApi
  URL = '#marketplace_api_http_domen_name'

  EXACT_ERROR_RAISER = {
    420 => ->(status, msg, mp_id) { raise MarketplaceAggregator::ApiLimitError.new(status, msg, mp_id) },
    401 => ->(status, msg, mp_id) { raise MarketplaceAggregator::ApiAccessDeniedError.new(status, msg, mp_id) },
    403 => ->(status, msg, mp_id) { raise MarketplaceAggregator::ApiAccessDeniedError.new(status, msg, mp_id) }
  }.freeze

  RANGE_ERROR_RAISER = {
    (400...500) => ->(status, msg, mp_id) { raise MarketplaceAggregator::ApiBadRequestError.new(status, msg, mp_id) },
    (500..) => ->(status, msg, mp_id) { raise MarketplaceAggregator::ApiError.new(status, msg, mp_id) }
  }.freeze

  attr_accessor :connection
  attr_reader :response_content_type, :status

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
    @status = response.status
    @response_content_type = content_type(response.headers)
    body = response_parse(response.body)
    raise_error(
      error_message(body)
    )

    [@status, response.headers, body]
  end

  def error_message(body)
    raise NotImplementedError, "#{self.class}.#{__method__}: #{I18n.t('errors.marketplace_has_not_been_selected')}"
  end

  def raise_error(message)
    return unless @raise_an_error

    EXACT_ERROR_RAISER[status]&.call(status, message, @marketplace_credential.id)

    RANGE_ERROR_RAISER.each do |k, v|
      v.call(status, message, @marketplace_credential.id) if k.include?(status)
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
