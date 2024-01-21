# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::Api::OfferMappings, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP POST Request' do
    context 'with a sufficient balance for requests' do
      it 'parses status, headers, body quickly' do
        stubs.post('/businesses/12345/offer-mappings.json') do |env|
          expect(env.url.path).to eq('/businesses/12345/offer-mappings.json')
          [
            200,
            {
              'Content-Type' => 'application/json',
              'Date' => 'Tue, 09 Jan 2024 14:04:20 GMT',
              'X-RateLimit-Resource-Limit' => '600',
              'X-RateLimit-Resource-Remaining' => '600',
              'X-RateLimit-Resource-Until' => 'Tue, 09 Jan 2024 14:05:00 GMT'
            },
            load_json('import/yandex_info_1')
          ]
        end

        expect(client).not_to receive(:sleep)
        status, headers, body = client.call(
          params: { limit: 1 }
        )

        expect(status).to eq(200)
        expect(headers['x-ratelimit-resource-remaining'].to_i).to eq(600)
        expect(body.dig(*%i[result offerMappings]).first.dig(*%i[offer offerId])).to eq('00040263')
        stubs.verify_stubbed_calls
      end
    end

    context 'with insufficient balance for requests' do
      it 'is waiting for rate_limits' do
        stubs.post('/businesses/12345/offer-mappings.json') do |env|
          expect(env.url.path).to eq('/businesses/12345/offer-mappings.json')
          [
            200,
            {
              'Content-Type' => 'application/json',
              'Date' => 'Tue, 09 Jan 2024 14:04:57 GMT',
              'X-RateLimit-Resource-Limit' => '600',
              'X-RateLimit-Resource-Remaining' => '4',
              'X-RateLimit-Resource-Until' => 'Tue, 09 Jan 2024 14:05:00 GMT'
            },
            load_json('import/yandex_info_1')
          ]
        end

        expect(client).to receive(:sleep).once.with(60 - 57 + 1)
        status, headers, body = client.call(
          params: { limit: 1 }
        )

        expect(status).to eq(200)
        expect(headers['x-ratelimit-resource-remaining'].to_i).to eq(4)
        expect(body.dig(*%i[result offerMappings]).first.dig(*%i[offer offerId])).to eq('00040263')
        stubs.verify_stubbed_calls
      end
    end

    context 'with an extended period in RPM' do
      it 'does not wait for rate_limits with the last X-RateLimit-Resource-Remaining \
          but gets a log entry' do
        stubs.post('/businesses/12345/offer-mappings.json') do |env|
          expect(env.url.path).to eq('/businesses/12345/offer-mappings.json')
          [
            200,
            {
              'Content-Type' => 'application/json',
              'Date' => 'Tue, 09 Jan 2024 14:04:57 GMT',
              'X-RateLimit-Resource-Limit' => '600',
              'X-RateLimit-Resource-Remaining' => '4',
              'X-RateLimit-Resource-Until' => 'Tue, 09 Jan 2024 14:06:00 GMT'
            },
            load_json('import/yandex_info_1')
          ]
        end

        expect(client).not_to receive(:sleep)
        expect(Rails.logger).to(
          receive(:error).with(/The duration of the RateLimit has been changed/).once
        )
        status, headers, body = client.call(
          params: { limit: 1 }
        )

        expect(status).to eq(200)
        expect(headers['x-ratelimit-resource-remaining'].to_i).to eq(4)
        expect(body.dig(*%i[result offerMappings]).first.dig(*%i[offer offerId])).to eq('00040263')
        stubs.verify_stubbed_calls
      end
    end

    context 'with broken headers in the response - missing date attribute - X-RateLimit-Resource-Until' do
      it 'gets a log entry' do
        stubs.post('/businesses/12345/offer-mappings.json') do |env|
          expect(env.url.path).to eq('/businesses/12345/offer-mappings.json')
          [
            200,
            {
              'Content-Type' => 'application/json',
              'Date' => 'Tue, 09 Jan 2024 14:04:57 GMT',
              'X-RateLimit-Resource-Limit' => '600',
              'X-RateLimit-Resource-Remaining' => '4'
              # 'X-RateLimit-Resource-Until' => 'Tue, 09 Jan 2024 14:05:00 GMT'
            },
            load_json('import/yandex_info_1')
          ]
        end

        expect(client).not_to receive(:sleep)
        expect(Rails.logger).to receive(:error).with(/TypeError:/).ordered.and_call_original
        expect(Rails.logger).to receive(:error).at_least(:once).with(instance_of(String)).ordered
        status, headers, body = client.call(
          params: { limit: 1 }
        )

        expect(status).to eq(200)
        expect(headers['x-ratelimit-resource-remaining'].to_i).to eq(4)
        expect(body.dig(*%i[result offerMappings]).first.dig(*%i[offer offerId])).to eq('00040263')
        stubs.verify_stubbed_calls
      end
    end
  end
end
