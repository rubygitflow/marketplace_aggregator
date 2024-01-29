# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::ProductsDownloader::LoadingInfoList, type: :service do
  let(:items) { [10077600] }

  describe 'successful loading of the product information list' do
    include_context 'with marketplace_credential ozon product/list'
    let(:obj) { Ozon::ProductsDownloader.new(marketplace_credential) { include described_module } }

    before do
      obj.download_product_info_list(items)
    end

    it 'returns an input list of products' do
      expect(obj.instance_variable_get(:@parsed_ids)).to eq items.map(&:to_s)
    end
  end

  describe 'Unsuccessful downloading of the product information list' do
    context 'with failed 500' do
      include_context 'when marketplace_credential ozon product/info 500 stub'
      let(:obj) { Ozon::ProductsDownloader.new(marketplace_credential) { include described_module } }

      it 'rejects data upload with an error in JSON format' do
        expect { obj.download_product_info_list(items) }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_info.status).to eq 500
      end
    end

    context 'with failed 502' do
      include_context 'when marketplace_credential ozon product/info 502 stub'
      let(:obj) { Ozon::ProductsDownloader.new(marketplace_credential) { include described_module } }

      it 'rejects data upload with an error in HTML format' do
        expect { obj.download_product_info_list(items) }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_info.status).to eq 502
      end
    end

    context 'with failed 204' do
      include_context 'when marketplace_credential ozon product/info 204 stub'
      let(:obj) { Ozon::ProductsDownloader.new(marketplace_credential) { include described_module } }

      it 'checks the empty body up in the response' do
        expect { obj.download_product_info_list(items) }.to raise_error(MarketplaceAggregator::ApiError)
        expect(obj.http_client_info.status).to eq 204
      end
    end
  end
end
