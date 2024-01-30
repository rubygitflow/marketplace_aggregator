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
        total = @parsed_ids.size
        Rails.logger.info "import: :mp_credential[#{@mp_credential.id}] — actual[#{total}] — Done"
        # 2. download products from the archive
        downloading_archived_products
        Rails.logger.info "import: :mp_credential[#{@mp_credential.id}] — archived[#{@parsed_ids.size - total}] — Done"
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
          if status != 200
            # To be safe, but we shouldn't get here.
            # This is possible if the status is < 400 and the status is != 200.
            raise MarketplaceAggregator::ApiError.new(
              status,
              I18n.t('errors.downloading_the_product_list'),
              mp_credential.id
            )
          end

          # rubocop:disable Lint/RedundantSplatExpansion
          items = body&.dig(*%i[result items]) || []
          # rubocop:enable Lint/RedundantSplatExpansion
          break if items.blank?

          return unless load_info?(items)

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

      def load_info?(items)
        # Unfortunately, the marketplace returns data in a circle from the beginning
        # of the list with last_id equal to the last element of the list of user data.
        # Therefore, we need to take measures to protect against the "endless cycle".
        items.map! { |elem| elem[:product_id] }
        return false if @parsed_ids.key?(items[0].to_s)

        download_product_info_list(items)
        true
      end

      private :downloading_archived_products, :downloading_unarchived_products, :circle_downloader, :load_info?
    end
  end
end
