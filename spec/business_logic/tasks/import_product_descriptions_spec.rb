# frozen_string_literal: true

# https://rspec.info/features/3-13/rspec-mocks/basics/spies/

require 'rails_helper'

RSpec.describe Tasks::ImportProductDescriptions, type: :business_logic do
  describe 'downloading product descriptions' do
    include_context 'with marketplace_credential ozon product/list'
    let!(:task) { described_class.new }

    before do
      ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'false'
    end

    it 'invokes ProductDescriptions::OzonImportJob' do
      allow(ProductDescriptions::OzonImportJob).to receive(:perform_later)
      task.call
      expect(ProductDescriptions::OzonImportJob).to have_received(:perform_later).once
    end
  end
end
