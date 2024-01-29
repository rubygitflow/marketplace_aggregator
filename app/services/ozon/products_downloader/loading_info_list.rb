# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoListV2

module Ozon
  class ProductsDownloader
    module LoadingInfoList
      include Ozon::ProductsDownloader::ImportingScheme

      def download_product_info_list(items)
        return if items.blank?

        status, _, body = @http_client_info.call(
          body: { product_id: items }
        )

        if status == 200
          # rubocop:disable Lint/RedundantSplatExpansion
          list = body&.dig(*%i[result items]) || []
          # rubocop:enable Lint/RedundantSplatExpansion
          return if list.blank?

          import_payload(list)
        else # any other status anyway
          # To be safe, but we shouldn't get here.
          # This is possible if the status is < 400 and the status is != 200.
          raise MarketplaceAggregator::ApiError.new(
            status,
            I18n.t('errors.downloading_the_product_info_list'),
            mp_credential.id
          )
        end
      end
    end
  end
end
