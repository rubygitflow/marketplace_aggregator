# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Products::ImportJob, type: :job do
  describe 'with filled marketplace_credential' do
    let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }

    describe '#perform_later' do
      it 'runs ImportJob in queue' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          described_class.perform_later
        end.to have_enqueued_job(described_class).exactly(:once)
      end
    end

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test
      let!(:test_time) { Time.current }

      before { described_class.perform_now(true, marketplace_credential.id) }

      it 'is updated (marketplace_credential) at the current time' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be > test_time
      end
    end
  end

  describe 'with empty marketplace_credential' do
    let!(:marketplace_credential) { create(:marketplace_credential, :not_authentic_on_yandex) }

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test

      before { described_class.perform_now(true, marketplace_credential.id) }

      it 'is not updated (marketplace_credential) at the current time' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be_nil
      end
    end
  end

  describe 'with right marketplace_credential for marketplace with missing handler implementation' do
    let!(:marketplace_credential) { create(:marketplace_credential, :dzen) }

    describe '#perform_now' do
      ActiveJob::Base.queue_adapter = :test

      before { described_class.perform_now(true, marketplace_credential.id) }

      it 'is not updated (marketplace_credential) at the current time' do
        expect(MarketplaceCredential.find(marketplace_credential.id).last_sync_at_products).to be_nil
      end
    end
  end
end
