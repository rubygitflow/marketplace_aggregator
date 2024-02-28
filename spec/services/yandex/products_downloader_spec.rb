# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::ProductsDownloader, type: :service do
  describe 'successful downloading of products' do
    include_context 'with marketplace_credential yandex offer-mappings'
    let(:obj) { described_class.new(marketplace_credential) }

    context 'when the products still do not exist' do
      before do
        ENV['PRODUCTS_DOWNLOADER_FROM_ARCHIVE'] = 'true'
        obj.call
      end

      it 'gains new records about the products on the marketplace' do
        expect(Product.count).to eq 3
      end

      it 'imports product list' do
        expect(obj.parsed_ids).to eq %w[
          00040263
          00040265
          00040264
        ]
      end

      it 'imports product description' do
        product = Product.find_by(offer_id: '00040263')
        expect(product.name).to eq 'Ножницы садовые 300 мм серебряный/зеленый'
        expect(product.price).to eq '(3790.9,RUR)'
        expect(product.status).to eq 'published'
        expect(product.barcodes).to eq ['4277136502815']
        expect(product.skus).to eq ['100473183912']
        expect(product.scrub_status).to eq 'success'
        expect(product.schemes).to eq %w[DBS EXPRESS FBS FBY]
        expect(product.stock).to be_nil
        expect(product.category_title).to eq 'Садовый инвентарь'
        expect(product.product_id).to eq '1755955930'
      end

      it 'imports product without product_id' do
        product = Product.find_by(offer_id: '00040265')
        expect(product.name).to eq 'Ножницы садовые 200 мм серебряный/зеленый'
        expect(product.price).to eq '(490.9,RUR)'
        expect(product.status).to eq 'published'
        expect(product.barcodes).to eq ['4277136502820']
        expect(product.skus).to eq []
        expect(product.scrub_status).to eq 'success'
        expect(product.schemes).to eq %w[DBS EXPRESS FBS FBY]
        expect(product.stock).to be_nil
        expect(product.category_title).to eq 'Садовый инвентарь'
        expect(product.product_id).to be_nil
      end
    end

    context 'when product already exists in the DB' do
      let!(:outdated_product) do
        create(:product,
               marketplace_credential:,
               offer_id: '00040264',
               product_id: '1755955934',
               name: 'Ножницы садовые 400 мм серебряный/зеленый',
               description: 'Des_1',
               skus: %w[100473183914],
               images: [],
               barcodes: %w[4277136502814],
               status: 'archived',
               scrub_status: 'success',
               price: '(0,RUR)',
               stock: nil,
               category_title: 'Садовый инвентарь',
               schemes: %w[DBS EXPRESS FBS FBY])
      end
      let!(:outdated_product_2) do
        create(:product,
               marketplace_credential:,
               offer_id: '00040263',
               product_id: nil,
               name: 'Ножницы садовые 300 мм серебряный/зеленый',
               description: 'Ножницы садовые KNAUF UMM 300 мм серебряный/зеленый',
               skus: %w[],
               images: [],
               barcodes: %w[4277136502815],
               status: 'unpublished',
               scrub_status: 'success',
               price: '(3790.9,RUR)',
               stock: nil,
               category_title: 'Садовый инвентарь',
               schemes: %w[DBS EXPRESS FBS FBY])
      end
      let!(:old_time_outdated_product) { outdated_product.updated_at }

      before do
        ENV['PRODUCTS_DOWNLOADER_FROM_ARCHIVE'] = 'true'
        obj.call
      end

      it 'changes the entry for the same product with new description' do
        p = Product.find(outdated_product.id)
        expect(p.updated_at).to be > old_time_outdated_product
        expect(p.description).to eq(
          'Ножницы садовые KNAUF подходят для первичной обработки поросли веток до 25 мм толщиной.'
        )
      end

      it 'changes the entry for the same product with new product_id' do
        p = Product.find(outdated_product_2.id)
        expect(p.updated_at).to be > old_time_outdated_product
        expect(p.product_id).to eq('1755955930')
        expect(p.status).to eq('published')
        expect(p.skus).to eq(['100473183912'])
      end
    end
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
