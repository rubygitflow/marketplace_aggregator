# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketplaceInteraction::ImportOzonCategoriesJob, type: :job do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }

  describe '#perform_later' do
    it 'runs ImportOzonCategoriesJob in a queue' do
      ActiveJob::Base.queue_adapter = :test

      expect do
        described_class.perform_later
      end.to have_enqueued_job(described_class).exactly(:once)
    end
  end

  describe '#perform_now' do
    ActiveJob::Base.queue_adapter = :test

    context 'with recording to the database' do
      include_context 'with marketplace_credential ozon description-category/tree'

      before { described_class.perform_now }

      it 'is executed fully' do
        expect(OzonCategory.count).to eq 15
      end
    end

    context 'without recording to the database' do
      include_context 'when marketplace_credential ozon description-category/tree 500 stub'

      before { described_class.perform_now }

      it 'is executed fully' do
        expect(OzonCategory.count).to eq 0
      end
    end
  end
end
