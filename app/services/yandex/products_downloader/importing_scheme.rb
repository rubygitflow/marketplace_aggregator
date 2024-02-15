# frozen_string_literal: true

module Yandex
  class ProductsDownloader
    module ImportingScheme
      def import_payload(items)
        list = items.each_with_object({}) { |item, res| res[item[:offer][:offerId]] = item }
        # 1. making changes to existing products
        exists = verify_existing_products(list)
        # 2. adding new products
        add_new_products(list, list.keys - exists)
      end

      def verify_existing_products(list)
        exists = []
        Product.where(
          marketplace_credential_id: mp_credential.id,
          offer_id: list.keys
        ).find_each do |product|
          exists << product.offer_id
          product = prepare_product(product, list[product.offer_id])
          @parsed_ids << product.offer_id
          # We can record the changes somewhere.
          # pp("product.changes=",product.changes) if product.changed?
          product.save! if product.changed?
        end
        exists
      end

      def add_new_products(list, rest)
        new_products = []
        rest.each do |id|
          product = Product.new(
            marketplace_credential_id: mp_credential.id,
            offer_id: id
          )
          new_products << prepare_product(product, list[id])
          @parsed_ids << id
        end
        Product.import(new_products) if new_products.any?
      end

      def prepare_product(product, item)
        offer = item[:offer]
        mapping = item[:mapping]
        product.assign_attributes(
          {
            name:           offer.fetch(:name, ''),
            barcodes:       offer.fetch(:barcodes, []),
            price:          find_price(offer),
            status:         find_status(offer),
            schemes:        find_schemes(offer),
            images:         offer.fetch(:pictures, []),
            description:    offer.fetch(:description, nil),
            product_id:     mapping.fetch(:marketModelId, nil),
            skus:           find_skus(mapping),
            category_title: find_category_title(offer, mapping),
            scrub_status:   'success'
          }
        )
        product
      end

      def find_price(offer)
        "(#{offer.dig(:basicPrice, :value) || 0},#{offer.dig(:basicPrice, :currencyId) || 'RUR'})".sub(
          '.0,', ','
        )
      end

      def find_status(offer)
        (@archive ? 'archived' : nil) ||
          Handles::ProductsDownloader.take_yandex_card_status(offer)
      end

      def find_schemes(offer)
        offer.fetch(:sellingPrograms, []).filter_map do |elem|
          elem[:sellingProgram] if elem[:status] == 'FINE'
        end.sort
      end

      def find_category_title(offer, mapping)
        offer.fetch(:category, nil) ||
          mapping.fetch(:marketCategoryName, nil)
      end

      def find_skus(mapping)
        sku = mapping.fetch(:marketSku, nil)
        sku ? [sku] : []
      end

      private :import_payload, :prepare_product, :verify_existing_products, :add_new_products,
              :find_price, :find_status, :find_schemes, :find_category_title, :find_skus
    end
  end
end
