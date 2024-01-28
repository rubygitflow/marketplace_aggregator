# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::ProductsDownloader, type: :service do
  describe 'successful downloading of products' do
    include_context 'with marketplace_credential ozon product/list'
    let(:obj) { described_class.new(marketplace_credential) }

    before do
      obj.call
    end

    it 'gains new records about the products on the marketplace' do
      expect(Product.count).to eq 0
    end

    it 'imports product list' do
      expect(obj.parsed_ids).to eq %w[
        10077600
        10077605
        10077606
        10077607
        10077604
        10077608
        10077611
      ]
    end

    it 'imports product description' do
      # product = Product.find_by(product_id: '10077607')
      # expect(product.name).to eq 'Полусапоги женские р.29'
      # expect(product.price).to eq '(345,RUR)'
      # expect(product.status).to eq 'published'
      # expect(product.barcodes).to eq ['461010135400', 'OZN34095273']
      # expect(product.skus).to eq ['123567', '123568']
      # expect(product.scrub_status).to eq 'success'
      # expect(product.schemes).to eq %w[fbo fbs]
      # expect(product.stock).to eq 1
      # expect(product.offer_id).to eq 'Арт.B.син р.29'
      # expect(product.description).to eq 'Des_3'
    end
  end

  describe 'Unsuccessful downloading of products' do
    context 'with failed 500' do
      include_context 'when marketplace_credential ozon product/list 500 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'rejects data upload with an error in JSON format' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_list.status).to eq 500
      end
    end

    context 'with failed 502' do
      include_context 'when marketplace_credential ozon product/list 502 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'rejects data upload with an error in HTML format' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_list.status).to eq 502
      end
    end

    context 'with failed 204' do
      include_context 'when marketplace_credential ozon product/list 204 stub'
      let(:obj) { described_class.new(marketplace_credential) }

      it 'checks the empty body in the response' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_list.status).to eq 204
      end
    end
  end
end
