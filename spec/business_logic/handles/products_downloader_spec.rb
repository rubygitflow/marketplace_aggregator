# frozen_string_literal: true

require 'rails_helper'

class OzonDescriptions
  def self.default_process?
    Handles::ProductsDownloader.ozon_descriptions_statement?
  end
end

class ArchivedProducts
  def self.default_process?
    Handles::ProductsDownloader.archived_statement?
  end
end

RSpec.describe Handles::ProductsDownloader, type: :business_logic do
  context 'when PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS is true' do
    before do
      ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'true'
    end

    it 'reads the correct env parameter using #ozon_descriptions_statement?' do
      expect(OzonDescriptions.default_process?).to eq true
    end
  end

  context 'when PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS is false' do
    before do
      ENV['PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS'] = 'false'
    end

    it 'reads the correct env parameter using #ozon_descriptions_statement?' do
      expect(OzonDescriptions.default_process?).to eq false
    end
  end

  context 'when PRODUCTS_DOWNLOADER_FROM_ARCHIVE is true' do
    before do
      ENV['PRODUCTS_DOWNLOADER_FROM_ARCHIVE'] = 'true'
    end

    it 'reads the correct env parameter using #archived_statement?' do
      expect(ArchivedProducts.default_process?).to eq true
    end
  end

  context 'when PRODUCTS_DOWNLOADER_FROM_ARCHIVE is false' do
    before do
      ENV['PRODUCTS_DOWNLOADER_FROM_ARCHIVE'] = 'false'
    end

    it 'reads the correct env parameter using #archived_statement?' do
      expect(ArchivedProducts.default_process?).to eq false
    end
  end
end
