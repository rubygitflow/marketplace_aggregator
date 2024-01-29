# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductList

module Ozon
  class ProductsDownloader
    module DownloadingScheme
      include Ozon::ProductsDownloader::LoadingInfoList

      PAGE_LIMIT = 1000

      def download_products
        # 1. download products not from the archive
        downloading_unarchived_products
        # 2. download products from the archive
        downloading_archived_products
      end

      def downloading_archived_products
        if Handles::ProductsDownloader.from_archive
          @archive = true
          circle_downloader
        end
      end

      def downloading_unarchived_products
        @archive = false
        circle_downloader
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Metrics/MethodLength
      def circle_downloader
        page_tokens = {}
        loop do
          status, _, body = @http_client_list.call(
            body: {
              filter: {
                visibility: (@archive ? 'ARCHIVED' : 'ALL')
              }.merge(page_tokens),
              limit: PAGE_LIMIT
            }
          )

          if status == 200
            # rubocop:disable Lint/RedundantSplatExpansion
            items = body&.dig(*%i[result items]) || []
            # rubocop:enable Lint/RedundantSplatExpansion
            break if items.blank?

            # for
            # @parsed_ids += items.map { |elem| elem[:product_id].to_s }
            download_product_info_list(
              items.map { |elem| elem[:product_id] }
            )
          else # any other status anyway
            # To be safe, but we shouldn't get here.
            # This is possible if the status is < 400 and the status is != 200.
            raise MarketplaceAggregator::ApiError.new(
              status,
              I18n.t('errors.downloading_the_product_list'),
              mp_credential.id
            )
          end

          # rubocop:disable Lint/RedundantSplatExpansion
          page_token = body&.dig(*%i[result last_id])
          # rubocop:enable Lint/RedundantSplatExpansion
          if page_token.blank?
            break
          else
            page_tokens = { last_id: page_token }
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/PerceivedComplexity
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/AbcSize

      private :downloading_archived_products, :downloading_unarchived_products, :circle_downloader
    end
  end
end
