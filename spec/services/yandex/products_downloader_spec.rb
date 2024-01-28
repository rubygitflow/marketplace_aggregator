# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::ProductsDownloader, type: :service do
  describe 'successful downloading of products' do
    include_context 'with marketplace_credential yandex offer-mappings'
    let(:obj) { described_class.new(marketplace_credential) }

    before do
      obj.call
    end

    it 'gains new records about the products on the marketplace' do
      expect(Product.count).to eq 2
    end

    it 'imports product list' do
      expect(obj.parsed_ids).to eq %w[
        00040263
        00040264
      ]
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'imports product description' do
      product = Product.find_by(offer_id: '00040263')
      expect(product.name).to eq 'Ножницы садовые 300 мм серебряный/зеленый'
      expect(product.price).to eq '(3790.9,RUR)'
      expect(product.status).to eq 'published'
      expect(product.barcodes).to eq ['4277136502815']
      expect(product.skus).to eq ['100473183912']
      expect(product.scrub_status).to eq 'success'
      expect(product.schemes).to eq %w[DBS EXPRESS FBS FBY]
      expect(product.stock).to eq nil
      expect(product.product_id).to eq '1755955930'
    end
    # rubocop:enable RSpec/MultipleExpectations
  end

  describe 'Unsuccessful downloading of products' do
    context 'with failed 500' do
      include_context 'when marketplace_credential yandex offer-mappings 500 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'rejects data upload with an error' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client.status).to eq 500
      end
    end

    context 'with failed 503' do
      include_context 'when marketplace_credential yandex offer-mappings 503 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'rejects data upload with an error' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client.status).to eq 503
      end
    end

    context 'with failed 204' do
      include_context 'when marketplace_credential yandex offer-mappings 204 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'checks the empty body in the response' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client.status).to eq 204
      end
    end
  end
end
