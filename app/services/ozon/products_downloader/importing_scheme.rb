# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoDescription

module Ozon
  class ProductsDownloader
    module ImportingScheme
      def import_payload(items)
        items.each do |item|
          product_id = item[:id]
          next unless product_id

          @parsed_ids << product_id.to_s
          @product = Product.find_or_initialize_by(
            marketplace_credential_id: mp_credential.id,
            product_id:
          )
          prepare_product(item)
          # We can record the changes somewhere.
          # pp("@product.changes=",@product.changes) if @product.changed?
          @product.save! if @product.changed?
        end
      end

      # rubocop:disable Metrics/AbcSize
      def prepare_product(item)
        @product.name           = item.fetch(:name, '')
        @product.offer_id       = item[:offer_id]
        @product.stock          = item.dig(:stocks, :present)
        @product.images         = item[:images]
        @product.price          = find_price(item)
        @product.barcodes       = find_barcodes(item)
        @product.skus           = find_skus(item)
        @product.category_title = find_category_title(item)
        @product.status         = find_status(item)
        @product.schemes        = find_schemes(item)
        @product.description    = load_description(item)
        @product.scrub_status   = 'success'
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

        category = OzonCategory.find_by(
          description_category_id: item[:description_category_id] || 0,
          type_id: item[:type_id] || 0
        )
        return if category.nil?

        "#{category.category_name}/#{category.type_name}"
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

      def load_description(item)
        status, _, body = @http_client_description.call(
          body: { product_id: item[:id] }
        )
        body.dig(:result, :description) if status == 200
      rescue MarketplaceAggregator::ApiError => e
        ErrorLogger.push e
        # does not matter.
        # We can allow skip an arror, and deal with the error later
        # TODO: to send the report somewhere
        nil
      end

      private :import_payload, :prepare_product, :find_price, :find_barcodes,
              :find_skus, :find_category_title, :find_status, :find_schemes,
              :load_description
    end
  end
end
