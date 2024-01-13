# frozen_string_literal: true

module BusinessLogic
  module Handles
    class ProductsDownloader
      class << self
        def from_archive
          ENV.fetch('PRODUCTS_DOWNLOADER_FROM_ARCHIVE') || false
        end
      end
    end
  end
end
