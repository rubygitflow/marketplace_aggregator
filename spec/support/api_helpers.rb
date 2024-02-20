# frozen_string_literal: true

module ApiHelpers
  def json
    @json = JSON.parse(response.body).deep_symbolize_keys
  end
end
