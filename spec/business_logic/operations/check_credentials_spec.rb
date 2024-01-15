# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::CheckCredentials, type: :business_logic do
  context 'with valid credentials' do
    let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'business_id' => '12345',
        'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
        errors: 'Token is invalid (Error parsing token: malformed embedded info)'
      }
    end

    it 'does CheckCredentials fine with correct token' do
      expect(operation.call).to eq(updated_response)
    end
  end

  describe 'with invalid credentials' do
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

  describe 'with valid credentials and unknown marketplace' do
    let!(:marketplace_credential) { create(:marketplace_credential, :dzen) }
    let!(:operation) { described_class.new(marketplace_credential) }
    let(:updated_response) do
      {
        'client_id' => '12345',
        'api_key' => '1234567890',
        errors: 'uninitialized constant Dzen'
      }
    end

    it 'does not CheckCredentials fine with correct token' do
      expect(operation.call).to eq(updated_response)
    end
  end
end
