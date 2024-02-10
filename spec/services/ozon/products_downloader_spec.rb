# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::ProductsDownloader, type: :service do
  before do
    ENV['PRODUCTS_DOWNLOADER_FROM_ARCHIVE'] = 'true'
  end

  describe 'successful downloading of new products' do
    include_context 'with marketplace_credential ozon product/list'
    let(:obj) { described_class.new(marketplace_credential) }
    let!(:category1) { create(:ozon_category, :с_15621048_91258) }
    let!(:category2) { create(:ozon_category, :с_15621032_0) }

    context 'when the products still do not exist' do
      context "with ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'true'" do
        before do
          ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'true'
          obj.call
        end

        it 'gains new records about the products on the marketplace' do
          expect(Product.count).to eq 7
        end

        it 'imports product list' do
          expect(obj.parsed_ids.keys).to eq %w[
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

      context "with ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'false'" do
        before do
          ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'false'
          obj.call
        end

        it 'imports a product description, skipping the description' do
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
          expect(product.description).to eq nil
        end
      end
    end

    context 'when product already exists in the DB' do
      let!(:unchanged_product) do
        create(:product,
               marketplace_credential:,
               offer_id: 'Арт.B.син р.29',
               product_id: '10077607',
               name: 'Полусапоги женские р.29',
               description: 'Des_3',
               skus: %w[123567 123568],
               images: %w[
                 https://cdn1.ozone.ru/s3/multimedia-h/6118756313.jpg
                 https://cdn1.ozone.ru/s3/multimedia-d/6118756309.jpg
               ],
               barcodes: %w[461010135400 OZN34095273],
               status: 'published',
               scrub_status: 'success',
               price: '(345,RUB)',
               stock: 1,
               category_title: 'Обувь/Повседневная обувь/Полусапоги',
               schemes: %w[fbo fbs])
      end
      let!(:old_time_unchanged_product) { unchanged_product.updated_at }

      let!(:product_without_images) do
        create(:product,
               marketplace_credential:,
               offer_id: 'Арт.B.син р.24',
               product_id: '10077606',
               name: 'Полусапоги женские р.24',
               description: 'Des_2',
               skus: %w[123567 123568],
               images: nil,
               barcodes: %w[461010135400 OZN34095273],
               status: 'published',
               scrub_status: 'success',
               price: '(345,RUB)',
               stock: 1,
               category_title: 'Обувь/Повседневная обувь/Полусапоги',
               schemes: %w[fbo fbs])
      end
      let!(:old_time_product_without_images) { product_without_images.updated_at }

      let!(:product_with_outdated_description) do
        create(:product,
               marketplace_credential:,
               offer_id: 'Арт.B.син р.30',
               product_id: '10077605',
               name: 'Полусапоги женские р.24',
               description: 'Des_1000000',
               skus: %w[123567 123568],
               images: %w[
                 https://cdn1.ozone.ru/s3/multimedia-h/6118756313.jpg
                 https://cdn1.ozone.ru/s3/multimedia-d/6118756309.jpg
               ],
               barcodes: %w[461010135400 OZN34095273],
               status: 'published',
               scrub_status: 'success',
               price: '(345,RUB)',
               stock: 1,
               category_title: 'Обувь/Повседневная обувь/Полусапоги',
               schemes: %w[fbo fbs])
      end
      let!(:old_time_product_with_outdated_description) { product_with_outdated_description.updated_at }

      before do
        ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'true'
        obj.call
      end

      it 'does not change the entry for the same product from the marketplace' do
        expect(Product.find(unchanged_product.id).updated_at).to eq old_time_unchanged_product
      end

      it 'changes the entry for the same product with new images' do
        expect(
          Product.find(product_without_images.id).updated_at
        ).to be > old_time_product_without_images
        expect(Product.find(unchanged_product.id).images).to eq %w[
          https://cdn1.ozone.ru/s3/multimedia-h/6118756313.jpg
          https://cdn1.ozone.ru/s3/multimedia-d/6118756309.jpg
        ]
      end

      it 'changes the entry for the same product with new description' do
        p = Product.find(product_with_outdated_description.id)
        expect(p.updated_at).to be > old_time_product_with_outdated_description
        expect(p.description).to eq 'Des_1'
      end
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
