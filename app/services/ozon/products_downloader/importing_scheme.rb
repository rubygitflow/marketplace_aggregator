# frozen_string_literal: true

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

      def prepare_product(item)
        @product.name = item.fetch(:name, '')
        @product.offer_id = item[:offer_id]
      end

      private :import_payload, :prepare_product
    end
  end
end
