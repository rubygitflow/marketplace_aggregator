# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::Api, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP GET Request' do
    it 'parses status, headers, body' do
      stubs.get('/') do |env|
        expect(env.url.path).to eq('')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"origin": "127.0.0.1"}'
        ]
      end

      status, headers, body = client.call(method: :get)
      expect(status).to eq(200)
      expect(headers['Content-Type']).to eq('application/json')
      expect(body[:origin]).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end
  end

  describe 'HTTP POST Request' do
    it 'parses status, headers, body' do
      stubs.post('/') do |env|
        expect(env.url.path).to eq('')
        [
          200,
          { 'Content-Type': 'application/json' },
          '{"origin": "127.0.0.1"}'
        ]
      end

      status, headers, body = client.call(
        method: :post,
        params: { limit: 1 },
        body: { id: 4321 }
      )
      expect(status).to eq(200)
      expect(headers['Content-Type']).to eq('application/json')
      expect(body[:origin]).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end
  end
end
