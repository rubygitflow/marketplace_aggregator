# frozen_string_literal: true

module MarketplaceAggregator
  class ApiError < StandardError
    def initialize(status, message, mp_credential_id)
      message = "Status: #{status}; Error: #{message}; Account: #{mp_credential_id}"
      super(message)
    end
  end
end
