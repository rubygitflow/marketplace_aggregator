# frozen_string_literal: true

module Handles
  class ProductsDownloader
    extend YandexProductStatus
    extend OzonProductStatus

    class << self
      def from_archive
        ENV.fetch('PRODUCTS_DOWNLOADER_FROM_ARCHIVE', nil) || false
      end
    end
  end
end
