# frozen_string_literal: true

module Ozon
  class ProductsDownloader
    module ImportingScheme
      def import_payload(items)
        list = items.each_with_object({}) { |item, res| res[item[:id].to_s] = item }
        # 1. making changes to existing products
        exists = verify_existing_products(list)
        # 2. adding new products
        add_new_products(list, list.keys - exists)
      end

      def verify_existing_products(list)
        exists = []
        Product.where(
          marketplace_credential_id: mp_credential.id,
          product_id: list.keys
        ).find_each do |product|
          exists << product.product_id
          product = prepare_product(product, list[product.product_id])
          @parsed_ids[product.product_id] = 1
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
            product_id: id
          )
          new_products << prepare_product(product, list[id])
          @parsed_ids[id] = 1
        end
        Product.import(new_products) if new_products.any?
      end

      # rubocop:disable Metrics/AbcSize
      def prepare_product(product, item)
        product.name           = item.fetch(:name, '')
        product.offer_id       = item[:offer_id]
        product.stock          = item.dig(:stocks, :present)
        product.images         = item[:images]
        product.price          = find_price(item)
        product.barcodes       = find_barcodes(item)
        product.skus           = find_skus(item)
        product.category_title = find_category_title(item)
        product.status         = find_status(item)
        product.schemes        = find_schemes(item)
        product.scrub_status   = 'success'
        product
      end
      # rubocop:enable Metrics/AbcSize

      def find_price(item)
        "(#{item[:marketing_price].to_f},#{item[:currency_code] || 'RUB'})".sub(
          '.0,', ','
        )
      end

      def find_barcodes(item)
        item[:barcodes].blank? ? item[:barcode] : item[:barcodes]
      end

      def find_skus(item)
        skus = [item[:sku], item[:fbo_sku], item[:fbs_sku]]
        skus += item[:sources]&.map { |elem| elem[:sku] } || []
        skus.select { |sku| sku&.positive? }.uniq.sort.map(&:to_s)
      end

      def find_category_title(item)
        return if item[:description_category_id].blank? && item[:type_id].blank?

        CashOzonCategory.get(
          item[:description_category_id] || 0,
          item[:type_id] || 0
        )
      end

      def find_status(item)
        (@archive ? 'archived' : nil) ||
          Handles::ProductsDownloader.take_ozon_card_status(item)
      end

      def find_schemes(item)
        schemes = []
        schemes << 'fbo' if item[:fbo_sku]&.positive?
        schemes << 'fbs' if item[:fbs_sku]&.positive?
        return schemes.sort if schemes.any?

        item[:sources]&.filter_map { |elem| elem[:source] if elem[:is_enabled] }&.sort
      end

      private :import_payload, :prepare_product, :find_price, :find_barcodes,
              :find_skus, :find_category_title, :find_status, :find_schemes,
              :verify_existing_products, :add_new_products
    end
  end
end
