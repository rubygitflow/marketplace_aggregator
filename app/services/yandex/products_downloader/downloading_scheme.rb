# frozen_string_literal: true

module Yandex
  class ProductsDownloader
    module DownloadingScheme
      include Yandex::ProductsDownloader::ImportingScheme

      PAGE_LIMIT = 200
      LIMITS = { limit: PAGE_LIMIT }.freeze

      def download_products
        # 1. download products from the archive
        downloading_archived_products
        # 2. download products not from the archive
        downloading_unarchived_products
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

      def circle_downloader
        page_tokens = {}
        loop do
          status, _, body = @http_client.call(
            params: LIMITS.merge(page_tokens),
            body: { archived: @archive }
          )
          if status == 200
            # rubocop:disable Lint/RedundantSplatExpansion
            items = body&.dig(*%i[result offerMappings]) || []
            # rubocop:enable Lint/RedundantSplatExpansion
            break if items.blank?

            import_payload(items)
          else # any other status anyway
            raise ApiError.new(status, 'something went wrong', mp_credential.id)
          end

          # rubocop:disable Lint/RedundantSplatExpansion
          page_token = body&.dig(*%i[result paging nextPageToken])
          # rubocop:enable Lint/RedundantSplatExpansion
          if page_token.blank?
            break
          else
            page_tokens = { page_token: }
          end
        end
      end

      private :downloading_archived_products, :downloading_unarchived_products, :circle_downloader
    end
  end
end
