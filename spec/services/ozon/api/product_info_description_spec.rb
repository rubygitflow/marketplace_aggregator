# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::Api::ProductInfoDescription, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP POST' do
    context 'with a successful Request' do
      it 'parses status, headers, body quickly' do
        stubs.post('/v1/product/info/description') do |env|
          expect(env.url.path).to eq('/v1/product/info/description')
          [
            200,
            {
              'Content-Type' => 'application/json'
            },
            load_json('import/ozon_description_1')
          ]
        end

        status, headers, body = client.call

        expect(status).to eq(200)
        expect(headers['Content-Type']).to eq('application/json')
        expect(body.dig(:result, :description)).to include('Des_1')
        stubs.verify_stubbed_calls
      end
    end
  end
end
