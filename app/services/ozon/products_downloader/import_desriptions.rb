# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoDescription

module Ozon
  class ProductsDownloader
    module ImportDesriptions
      def downloading_product_desriptions
        return unless Handles::ProductsDownloader.ozon_descriptions

        Product.where(
          marketplace_credential_id: @mp_credential.id,
          product_id: @parsed_ids.keys
        ).find_in_batches(batch_size: 100) do |products|
          updated_products = []
          products.each do |product|
            product.description = load_description(product.product_id)
            updated_products << product if product.changed?
          end
          if updated_products.any?
            Product.import(updated_products,
                           on_duplicate_key_ignore: true,
                           on_duplicate_key_update: {
                             conflict_target: %i[
                               marketplace_credential_id
                               product_id
                               offer_id
                             ],
                             columns: %i[
                               description
                             ]
                           })
          end
        end
      end

      def load_description(id)
        status, _, body = @http_client_description.call(
          body: { product_id: id.to_i }
        )
        body.dig(:result, :description) if status == 200
      rescue MarketplaceAggregator::ApiError => e
        ErrorLogger.push e
        # does not matter.
        # We can allow skip an arror, and deal with the error later
        # TODO: to send the report somewhere
        nil
      end

      private :downloading_product_desriptions, :load_description
    end
  end
end
