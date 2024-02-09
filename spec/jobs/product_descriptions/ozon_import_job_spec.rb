# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ProductDescriptions::OzonImportJob, type: :job do
  context 'without previous Product list' do
    let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }

    describe '#perform_later' do
      it 'runs OzonImportJob in queue' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          described_class.perform_later
        end.to have_enqueued_job(described_class).exactly(:once)
      end
    end

    describe '#perform_now without downloaded Products' do
      ActiveJob::Base.queue_adapter = :test

      before do
        described_class.perform_now(true, marketplace_credential.id)
      end

      it 'skips adding a new product' do
        expect(Product.where(marketplace_credential_id: marketplace_credential.id).count).to eq 0
      end
    end
  end

  context 'with previous Product list' do
    include_context 'with marketplace_credential ozon product/list'
    let!(:product_with_description) do
      create(:product,
             marketplace_credential:,
             offer_id: 'Арт.B.син р.30',
             product_id: '10077605',
             name: 'Полусапоги женские р.24',
             description: 'Des_1000000',
             status: 'published',
             scrub_status: 'success')
    end

    ActiveJob::Base.queue_adapter = :test

    before do
      ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'false'
      described_class.perform_now(true, marketplace_credential.id)
    end

    it 'updates product descriptions' do
      product1 = Product.find_by(
        marketplace_credential_id: marketplace_credential.id,
        product_id: '10077605'
      )
      expect(product1.description).to eq 'Des_1'
    end
  end
end
