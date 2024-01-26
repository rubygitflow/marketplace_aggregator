# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::Api::DescriptionCategoryTree, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP POST Request' do
    context 'with a sufficient balance for requests' do
      it 'parses status, headers, body quickly' do
        stubs.post('/v1/description-category/tree') do |env|
          expect(env.url.path).to eq('/v1/description-category/tree')
          [
            200,
            {
              'Content-Type' => 'application/json'
            },
            load_json('import/ozon_category')
          ]
        end

        status, headers, body = client.call

        expect(status).to eq(200)
        expect(headers['Content-Type']).to eq('application/json')
        expect(body[:result].first[:category_name]).to eq('Одежда')
        stubs.verify_stubbed_calls
      end
    end
  end
end
