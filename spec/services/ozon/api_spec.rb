# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::Api, type: :service do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let(:stubs)  { Faraday::Adapter::Test::Stubs.new }
  let(:conn)   { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:client) { described_class.new(marketplace_credential) }

  before { client.connection = conn }

  describe 'HTTP GET Request' do
    it 'parses status, headers, body' do
      stubs.get('/') do |env|
        expect(env.url.path).to eq('/')
        [
          200,
          { 'content-type': 'application/json' },
          '{"origin": "127.0.0.1"}'
        ]
      end

      status, headers, body = client.call(method: :get)
      expect(status).to eq(200)
      expect(headers['content-type']).to eq('application/json')
      expect(body[:origin]).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end

    context 'with unknown response Content-Type' do
      it 'correctly analyzes status, headers, body' do
        stubs.get('/') do |env|
          expect(env.url.path).to eq('/')
          [
            200,
            { 'server': 'nginx' },
            '{"origin": "127.0.0.1"}'
          ]
        end

        status, headers, body = client.call(method: :get)
        expect(status).to eq(200)
        expect(headers['server']).to eq('nginx')
        expect(body.class.name).to eq('String')
        stubs.verify_stubbed_calls
      end
    end

    context 'with HTML response Content-Type' do
      it 'correctly analyzes status, headers, body' do
        stubs.get('/') do |env|
          expect(env.url.path).to eq('/')
          [
            200,
            { 'content-type': 'text/html' },
            <<~HTML
              <html>
              <head><title>502 Bad Gateway</title></head>
              <body>
              <center><h1>502 Bad Gateway</h1></center>
              <hr><center>nginx</center>
              </body>
              </html>
            HTML
          ]
        end

        status, headers, body = client.call(method: :get)
        expect(status).to eq(200)
        expect(headers['content-type']).to eq('text/html')
        expect(body).to include('502 Bad Gateway')
        stubs.verify_stubbed_calls
      end
    end
  end

  describe 'HTTP POST Request' do
    it 'parses status, headers, body' do
      stubs.post('/') do |env|
        expect(env.url.path).to eq('/')
        [
          200,
          { 'content-type': 'application/json' },
          '{"origin": "127.0.0.1"}'
        ]
      end

      status, headers, body = client.call(
        method: :post,
        params: { limit: 1 },
        body: { id: 4321 }
      )
      expect(status).to eq(200)
      expect(headers['content-type']).to eq('application/json')
      expect(body[:origin]).to eq('127.0.0.1')
      stubs.verify_stubbed_calls
    end

    context 'with unknown response Content-Type' do
      it 'correctly analyzes status, headers, body' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            200,
            { 'server': 'nginx' },
            '{"origin": "127.0.0.1"}'
          ]
        end

        status, headers, body = client.call(
          method: :post,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(200)
        expect(headers['server']).to eq('nginx')
        expect(body.class.name).to eq('String')
        stubs.verify_stubbed_calls
      end
    end

    context 'with HTML response Content-Type' do
      it 'correctly analyzes status, headers, body' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            200,
            { 'content-type': 'text/html' },
            <<~HTML
              <html>
              <head><title>502 Bad Gateway</title></head>
              <body>
              <center><h1>502 Bad Gateway</h1></center>
              <hr><center>nginx</center>
              </body>
              </html>
            HTML
          ]
        end

        status, headers, body = client.call(
          method: :post,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(200)
        expect(headers['content-type']).to eq('text/html')
        expect(body).to include('502 Bad Gateway')
        stubs.verify_stubbed_calls
      end
    end
  end

  describe 'HTTP POST Request with raising errors' do
    context 'when status = 500' do
      it 'may not cause an ApiError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            500,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        status, headers, body = client.call(
          method: :post,
          raise_an_error: false,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(500)
        expect(headers['content-type']).to eq('application/json')
        expect(body[:message]).to eq('details')
        stubs.verify_stubbed_calls
      end

      it 'causes ApiError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            500,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        expect do
          client.call(
            method: :post,
            raise_an_error: true,
            params: { limit: 1 },
            body: { id: 4321 }
          )
        end.to raise_error(MarketplaceAggregator::ApiError)
        stubs.verify_stubbed_calls
      end
    end

    context 'when status = 400' do
      it 'may not cause an ApiBadRequestError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            400,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        status, headers, body = client.call(
          method: :post,
          raise_an_error: false,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(400)
        expect(headers['content-type']).to eq('application/json')
        expect(body[:message]).to eq('details')
        stubs.verify_stubbed_calls
      end

      it 'causes ApiBadRequestError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            400,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        expect do
          client.call(
            method: :post,
            raise_an_error: true,
            params: { limit: 1 },
            body: { id: 4321 }
          )
        end.to raise_error(MarketplaceAggregator::ApiBadRequestError)
        stubs.verify_stubbed_calls
      end
    end

    context 'when status = 401' do
      it 'may not cause an ApiAccessDeniedError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            401,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        status, headers, body = client.call(
          method: :post,
          raise_an_error: false,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(401)
        expect(headers['content-type']).to eq('application/json')
        expect(body[:message]).to eq('details')
        stubs.verify_stubbed_calls
      end

      it 'causes ApiAccessDeniedError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            401,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        expect do
          client.call(
            method: :post,
            raise_an_error: true,
            params: { limit: 1 },
            body: { id: 4321 }
          )
        end.to raise_error(MarketplaceAggregator::ApiAccessDeniedError)
        stubs.verify_stubbed_calls
      end
    end

    context 'when status = 420' do
      it 'may not cause an ApiLimitError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            420,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        status, headers, body = client.call(
          method: :post,
          raise_an_error: false,
          params: { limit: 1 },
          body: { id: 4321 }
        )
        expect(status).to eq(420)
        expect(headers['content-type']).to eq('application/json')
        expect(body[:message]).to eq('details')
        stubs.verify_stubbed_calls
      end

      it 'causes ApiLimitError' do
        stubs.post('/') do |env|
          expect(env.url.path).to eq('/')
          [
            420,
            { 'content-type': 'application/json' },
            '{"code": 2, "message": "details"}'
          ]
        end

        expect do
          client.call(
            method: :post,
            raise_an_error: true,
            params: { limit: 1 },
            body: { id: 4321 }
          )
        end.to raise_error(MarketplaceAggregator::ApiLimitError)
        stubs.verify_stubbed_calls
      end
    end
  end
end
