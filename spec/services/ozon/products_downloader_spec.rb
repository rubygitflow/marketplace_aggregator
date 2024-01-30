# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::ProductsDownloader, type: :service do
  describe 'successful downloading of products' do
    include_context 'with marketplace_credential ozon product/list'
    let(:obj) { described_class.new(marketplace_credential) }
    let!(:category1) { create(:ozon_category, :с_15621048_91258) }
    let!(:category2) { create(:ozon_category, :с_15621032_0) }

    before do
      obj.call
    end

    it 'gains new records about the products on the marketplace' do
      expect(Product.count).to eq 7
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

    it 'imports a product with a single SKU' do
      product = Product.find_by(product_id: '10077605')
      expect(product.name).to eq 'Полусапоги женские р.30'
      expect(product.price).to eq '(345,RUB)'
      expect(product.status).to eq 'published'
      expect(product.barcodes).to eq %w[461010135400 OZN34095273]
      expect(product.skus).to eq %w[123567]
      expect(product.scrub_status).to eq 'success'
      expect(product.schemes).to eq []
      expect(product.stock).to eq 1
      expect(product.category_title).to eq 'Обувь/Повседневная обувь/Полусапоги'
      expect(product.offer_id).to eq 'Арт.B.син р.30'
      expect(product.description).to eq 'Des_1'
    end

    it 'imports a product description' do
      product = Product.find_by(product_id: '10077607')
      expect(product.name).to eq 'Полусапоги женские р.29'
      expect(product.price).to eq '(345,RUB)'
      expect(product.status).to eq 'published'
      expect(product.barcodes).to eq %w[461010135400 OZN34095273]
      expect(product.skus).to eq %w[123567 123568]
      expect(product.scrub_status).to eq 'success'
      expect(product.schemes).to eq %w[fbo fbs]
      expect(product.stock).to eq 1
      expect(product.category_title).to eq 'Обувь/Повседневная обувь/Полусапоги'
      expect(product.offer_id).to eq 'Арт.B.син р.29'
      expect(product.description).to eq 'Des_3'
    end

    it 'intercepts an error when can not importing a product description\
    for product_id:10077600' do
      product = Product.find_by(product_id: '10077600')
      expect(product.name).to eq 'Полусапоги детские р.20'
      expect(product.price).to eq '(234.9,RUB)'
      expect(product.status).to eq 'published'
      expect(product.barcodes).to eq %w[461010135400 OZN34095273]
      expect(product.skus).to eq %w[123567 123568]
      expect(product.scrub_status).to eq 'success'
      expect(product.schemes).to eq %w[fbo fbs]
      expect(product.stock).to eq 1
      expect(product.category_title).to eq 'Обувь/'
      expect(product.offer_id).to eq 'Арт.B.роз р.20'
      expect(product.description).to be_nil
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

      it 'checks the empty body up in the response' do
        expect { obj.call }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_list.status).to eq 204
      end
    end
  end
end
