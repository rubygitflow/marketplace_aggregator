# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::CheckCredentials, type: :business_logic do
  context 'with valid credentials to ozon' do
    let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'client_id' => '12345',
        'api_key' => 'f89e2ac7d650',
        errors: 'Invalid Api-Key, please contact support'
      }
    end

    it 'does CheckCredentials fine with "correct" api_key' do
      updated_credentials = operation.call
      expect(updated_credentials['client_id']).to eq(updated_response['client_id'])
      expect(updated_credentials['api_key']).to eq(updated_response['api_key'])
      expect(updated_credentials[:errors]).to include(updated_response[:errors])
    end
  end

  context 'with missing credentials to ozon' do
    let!(:marketplace_credential) { create(:marketplace_credential, :not_authentic_on_ozon) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        errors: 'empty credentials'
      }
    end

    it 'does CheckCredentials fine with broken token
        and marketplace_credential remains empty' do
      expect(operation.call).to eq(updated_response)
    end
  end

  context 'with wrong credentials to ozon' do
    let!(:marketplace_credential) { create(:marketplace_credential, :wrong_ozon) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'client_id' => 'f89e2ac7d650',
        'api_key' => '12345',
        errors: 'Client-Id and Api-Key headers are required'
      }
    end

    it 'does CheckCredentials fine with "correct" api_key' do
      updated_credentials = operation.call
      expect(updated_credentials['client_id']).to eq(updated_response['client_id'])
      expect(updated_credentials['api_key']).to eq(updated_response['api_key'])
      expect(updated_credentials[:errors]).to include(updated_response[:errors])
    end
  end

  context 'with valid credentials to yandex' do
    let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'business_id' => '12345',
        'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
        errors: 'Token is invalid (Error parsing token: malformed embedded info)'
      }
    end

    it 'does CheckCredentials fine with "correct" token' do
      updated_credentials = operation.call
      expect(updated_credentials['business_id']).to eq(updated_response['business_id'])
      expect(updated_credentials['token']).to eq(updated_response['token'])
      expect(updated_credentials[:errors]).to include(updated_response[:errors])
    end
  end

  context 'with invalid credentials to yandex' do
    let!(:marketplace_credential) { create(:marketplace_credential, :not_authentic_on_yandex) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        errors: 'empty credentials'
      }
    end

    it 'does CheckCredentials fine with broken token
        and marketplace_credential remains empty' do
      expect(operation.call).to eq(updated_response)
    end
  end

  context 'with wrong credentials to yandex' do
    let!(:marketplace_credential) { create(:marketplace_credential, :wrong_yandex) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'business_id' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
        'token' => '12345',
        errors: ' 400 '
      }
    end

    it 'does CheckCredentials fine with "correct" token' do
      updated_credentials = operation.call
      expect(updated_credentials['business_id']).to eq(updated_response['business_id'])
      expect(updated_credentials['token']).to eq(updated_response['token'])
      expect(updated_credentials[:errors]).to include(updated_response[:errors])
    end
  end

  context 'with valid credentials and unknown marketplace' do
    let!(:marketplace_credential) { create(:marketplace_credential, :dzen) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'client_id' => '12345',
        'api_key' => '1234567890',
        errors: 'uninitialized constant Dzen'
      }
    end

    it 'does not CheckCredentials fine with "correct" token' do
      expect(operation.call).to eq(updated_response)
    end
  end
end
