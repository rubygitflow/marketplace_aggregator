# frozen_string_literal: true

module Handles
  class ProductsDownloader
    extend YandexProductStatus
    extend OzonProductStatus

    class << self
      def from_archive?
        archived_statement?
      end

      def to_bool(inp)
        case inp
        when String
          case inp.downcase
          when '0', 'f', 'false', 'off', 'no'
            false
          when '1', 't', 'true', 'on', 'yes'
            true
          end
        end
      end

      def archived_statement?
        to_bool(ENV.fetch('PRODUCTS_DOWNLOADER_FROM_ARCHIVE', nil)) || false
      end

      def ozon_descriptions_statement?
        to_bool(ENV.fetch('PRODUCTS_DOWNLOADER_OZON_DESCRIPTIONS', nil)) || false
      end
    end
  end
end
