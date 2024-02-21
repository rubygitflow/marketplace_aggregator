# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CredentialsController, type: :controller do
  include_context 'with marketplace_credential yandex offer-mappings'
  # We already have spec/factories/clients.rb
  let!(:headers) do
    {
      'Content-Type': 'application/json',
      'HTTP_USER': '0856b4f9-eb4e-4602-8c06-8539d029a3bd'
    }
  end
  let!(:check_true) { { ok: true } }
  let!(:check_credentials_instance) { instance_double(Yandex::CheckCredentials) }

  before do
    request.headers.merge!(headers)
  end

  describe 'POST #create' do
    let!(:api_path) { 'create' }
    let!(:valid_params) do
      {
        'instance_name': 'YANDEX_TEST',
        'credentials': {
          'business_id': marketplace_credential.credentials['business_id'],
          'token': marketplace_credential.credentials['token']
        },
        'marketplace': 'YANDEX'
      }
    end

    context 'with valid attributes' do
      it 'returns http success' do
        # Deprecated!
        # https://rspec.info/features/3-12/rspec-mocks/working-with-legacy-code/any-instance/
        # allow_any_instance_of(Yandex::CheckCredentials).to receive(:call).and_return(check_true)
        # Admitted!
        # https://www.rubydoc.info/gems/rubocop-rspec/1.6.0/RuboCop/Cop/RSpec/AnyInstance
        allow(Yandex::CheckCredentials).to receive(:new).and_return(check_credentials_instance)
        allow(check_credentials_instance).to receive(:call).and_return(check_true)
        post api_path, params: valid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(response).to have_http_status(:success)
      end

      it 'returns new marketplace_credential' do
        # allow_any_instance_of(Yandex::CheckCredentials).to receive(:call).and_return(check_true)
        allow(Yandex::CheckCredentials).to receive(:new).and_return(check_credentials_instance)
        allow(check_credentials_instance).to receive(:call).and_return(check_true)
        # expect { post :create, params: valid_params }
        #   .to change(Product, :count).by(2)
        post api_path, params: valid_params
        expect(json[:marketplace_credential][:instance_name]).to eq('YANDEX_TEST')
        expect(json[:marketplace_credential][:client_id]).to eq('0856b4f9-eb4e-4602-8c06-8539d029a3bd')
        expect(json[:marketplace_credential][:is_valid]).to eq(true)
      end
    end

    # without stubs, we get a 403 (Forbidden)/ status from CheckCredentials
    context 'with invalid attributes' do
      it 'returns http Bad Request' do
        post api_path, params: valid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the reason for the Bad Request' do
        post api_path, params: valid_params

        expect(json[:errors].first[:title]).to eq(I18n.t('errors.credentials_are_invalid'))
        expect(json[:errors].first[:detail]).to include('Status: 403')
      end
    end
  end

  describe 'PATCH #update' do
    let!(:api_path) { 'update' }
    let!(:valid_params) { { 'id': marketplace_credential.id } }
    let!(:invalid_params) { { 'id': SecureRandom.uuid } }
    let!(:import_job) { class_double(Products::ImportJob) }

    context 'with valid attributes' do
      it 'returns http success' do
        allow(Products::ImportJob).to receive(:set).and_return(import_job)
        allow(import_job).to receive(:perform_later)

        patch api_path, params: valid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(response).to have_http_status(:success)
      end

      it 'returns details about the successful request' do
        allow(Products::ImportJob).to receive(:set).and_return(import_job)
        allow(import_job).to receive(:perform_later)

        patch api_path, params: valid_params

        expect(json[:messages].first[:title]).to eq(I18n.t('messages.process_has_started'))
        expect(json[:messages].first[:detail]).to eq(I18n.t('messages.check_in_ten_minutes'))
      end

      it 'returns http Too Many Requests' do
        3.times { marketplace_credential.reimport_products.poke }

        patch api_path, params: valid_params

        expect(response).to have_http_status(:too_many_requests)
      end

      it 'returns the reason for the Too Many Requests' do
        3.times { marketplace_credential.reimport_products.poke }

        patch api_path, params: valid_params

        expect(json[:errors].first[:title]).to eq(I18n.t('errors.too_many_requests'))
        expect(json[:errors].first[:detail]).to eq(I18n.t('errors.repeat_after_an_hour'))
      end
    end

    context 'with invalid attributes' do
      it 'returns http Not Found' do
        patch api_path, params: invalid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(response).to have_http_status(:not_found)
      end

      it 'returns the reason for the Bad Request' do
        patch api_path, params: invalid_params

        expect(json[:errors].first[:title]).to include(' not found')
        expect(json[:errors].first[:detail]).to eq(nil)
      end
    end
  end

  describe 'PATCH #archive' do
    let!(:api_path) { 'archive' }
    let!(:valid_params) do
      {
        'id': marketplace_credential.id,
        'value': 'true'
      }
    end
    let!(:invalid_params) do
      {
        'id': marketplace_credential.id,
        'value': '-'
      }
    end

    before do
      marketplace_credential.autoload_archives.value = false
    end

    it 'returns the new value for marketplace_credential' do
      patch api_path, params: valid_params

      expect(json[:marketplace_credential][:id]).to eq(marketplace_credential.id)
      expect(json[:marketplace_credential][:autoload_archives]).to eq(true)
      expect(MarketplaceCredential.find(marketplace_credential.id).autoload_archives.value).to eq(true)
    end

    it 'returns the old value for marketplace_credential' do
      patch api_path, params: invalid_params

      expect(json[:marketplace_credential][:id]).to eq(marketplace_credential.id)
      expect(json[:marketplace_credential][:autoload_archives]).to eq(false)
      expect(MarketplaceCredential.find(marketplace_credential.id).autoload_archives.value).to eq(false)
    end
  end
end
