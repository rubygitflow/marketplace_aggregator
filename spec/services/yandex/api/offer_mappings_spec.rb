# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::Api::OfferMappings, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP POST Request' do
    it 'parses status, headers, body' do
      stubs.post('/businesses/12345/offer-mappings.json') do |env|
        expect(env.url.path).to eq('/businesses/12345/offer-mappings.json')
        [
          200,
          {
            'Content-Type' => 'application/json',
            'date' => 'Tue, 09 Jan 2024 14:04:20 GMT',
            'x-ratelimit-resource-limit' => '600',
            'x-ratelimit-resource-remaining' => '600',
            'x-ratelimit-resource-until' => 'Tue, 09 Jan 2024 14:05:00 GMT'
          },
          load_json('import/yandex_info_1', symbolize: true).to_json
        ]
      end

      status, headers, body = client.call(
        params: { limit: 1 }
      )
      expect(status).to eq(200)
      expect(headers['x-ratelimit-resource-remaining']).to eq('600')
      expect(body.dig(*%i[result offerMappings]).first.dig(*%i[offer offerId])).to eq('00040263')
      stubs.verify_stubbed_calls
    end
  end
end
