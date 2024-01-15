# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Yandex::ProductsDownloader, type: :service do
  describe 'Download products' do
    include_context 'with marketplace_credential yandex offer-mappings'

    before do
      described_class.new(marketplace_credential).call
    end

    it 'gains new records of products on the marketplace' do
      expect(Product.count).to eq 2
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
      expect(product.schemes).to eq %w[FBS EXPRESS DBS FBY]
      expect(product.stock).to eq nil
      expect(product.product_id).to eq '1755955930'
    end
    # rubocop:enable RSpec/MultipleExpectations
  end
end
