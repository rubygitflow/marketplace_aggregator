# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketplaceInteraction::ImportProductsJob, type: :job do
  let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }

  describe '#perform_later' do
    it 'runs ImportProductsJob in queue' do
      ActiveJob::Base.queue_adapter = :test

      expect do
        described_class.perform_later
      end.to have_enqueued_job(described_class).exactly(:once)
    end
  end

  describe '#perform_now' do
    ActiveJob::Base.queue_adapter = :test
    let(:updated_response) do
      {
        'business_id' => '12345',
        'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
        'errors' => 'Token is invalid (Error parsing token: malformed embedded info)'
      }
    end

    before { described_class.perform_now }

    it 'is supplemented with an error (marketplace_credential.credentials)' do
      updated_credentials = MarketplaceCredential.find(marketplace_credential.id).credentials
      expect(updated_credentials['business_id']).to eq(updated_response['business_id'])
      expect(updated_credentials['token']).to eq(updated_response['token'])
      expect(updated_credentials['errors']).to include(updated_response['errors'])
    end
  end
end
