# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::Api::ProductInfoList, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP POST' do
    context 'with a successful Request' do
      it 'parses status, headers, body quickly' do
        stubs.post('/v2/product/info/list') do |env|
          expect(env.url.path).to eq('/v2/product/info/list')
          [
            200,
            {
              'Content-Type' => 'application/json'
            },
            load_json('import/ozon_info_all')
          ]
        end

        status, headers, body = client.call

        expect(status).to eq(200)
        expect(headers['Content-Type']).to eq('application/json')
        expect(body.dig(:result, :items).first[:name]).to eq('Полусапоги женские р.30')
        stubs.verify_stubbed_calls
      end
    end
  end
end
