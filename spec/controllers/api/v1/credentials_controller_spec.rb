# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::CredentialsController, type: :controller do
  describe 'POST #create' do
    include_context 'with marketplace_credential yandex offer-mappings'
    # We already have spec/factories/clients.rb
    let!(:api_path) { 'create' }
    let!(:headers) do
      {
        'Content-Type': 'application/json',
        'HTTP_USER': '0856b4f9-eb4e-4602-8c06-8539d029a3bd'
      }
    end
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
    let!(:check_true) { { ok: true } }
    let!(:check_credentials_instance) { instance_double(Yandex::CheckCredentials) }

    before do
      request.headers.merge!(headers)
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
        post :create, params: valid_params
        expect(json[:marketplace_credential][:instance_name]).to eq('YANDEX_TEST')
        expect(json[:marketplace_credential][:client_id]).to eq('0856b4f9-eb4e-4602-8c06-8539d029a3bd')
        expect(json[:marketplace_credential][:is_valid]).to eq(true)
      end
    end

    context 'with invalid attributes' do
      it 'returns http Bad Request' do
        # without stubs, we get a 403 (Forbidden)/ status from CheckCredentials
        post api_path, params: valid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns the reason for the Bad Request' do
        # without stubs, we get a 403 (Forbidden)/ status from CheckCredentials
        post api_path, params: valid_params
        # https://rspec.info/features/6-0/rspec-rails/matchers/have-http-status-matcher/
        expect(json[:errors].first[:title]).to eq(I18n.t('errors.credentials_are_invalid'))
        expect(json[:errors].first[:detail]).to include('Status: 403')
      end
    end
  end
end
