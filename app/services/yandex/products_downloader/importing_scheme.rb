# frozen_string_literal: true

require './app/business_logic/handles/products_downloader'

module Yandex
  class ProductsDownloader
    module ImportingScheme
      def import_payload(items)
        items.each do |item|
          offer_id = item[:offer][:offerId]
          next unless offer_id

          @parsed_ids << offer_id
          @product = Product.find_or_initialize_by(
            marketplace_credential_id: mp_credential.id,
            offer_id:
          )
          prepare_product(item)
          @product.save! if @product.changed?
        end
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def prepare_product(item)
        offer = item[:offer]
        @product.name = offer.fetch(:name, '')
        @product.barcodes = offer.fetch(:barcodes, [])
        @product.price = "(#{offer.dig(:basicPrice, :value) || 0},#{offer.dig(:basicPrice, :currencyId) || 'RUR'})"
        @product.status = (@archive ? 'archived' : nil) ||
                          BusinessLogic::Handles::ProductsDownloader.take_card_status(offer)
        @product.schemes = offer.fetch(:sellingPrograms, []).filter_map do |elem|
          elem[:sellingProgram] if elem[:status] == 'FINE'
        end
        @product.images = offer.fetch(:pictures, [])
        @product.name = offer.fetch(:name, '')

        @product.description = offer.fetch(:description, nil)

        mapping = item[:mapping]
        @product.product_id = mapping.fetch(:marketModelId, nil)
        sku = mapping.fetch(:marketSku, nil)
        @product.skus = sku ? [sku] : []

        @product.category_title = offer.fetch(:category, nil) ||
                                  mapping.fetch(:marketCategoryName, nil)
        @product.scrub_status = 'success'
      end
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      private :import_payload, :prepare_product
    end
  end
end
