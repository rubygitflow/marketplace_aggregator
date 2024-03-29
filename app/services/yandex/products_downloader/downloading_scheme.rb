# frozen_string_literal: true

module Yandex
  class ProductsDownloader
    module DownloadingScheme
      include Yandex::ProductsDownloader::ImportingScheme
      include MaBenchmarking

      PAGE_LIMIT = 200
      LIMITS = { limit: PAGE_LIMIT }.freeze

      def download_products
        # 1. download products not from the archive
        downloading_unarchived_products
        # 2. download products from the archive
        downloading_archived_products
      end

      def downloading_archived_products
        if @mp_credential.autoload_archives.value
          @archive = true
          benchmarking(
            -> { "import: :mp_credential[#{@mp_credential.id}] — archived[#{@parsed_ids.size - @total}] — Done" }
          ) { circle_downloader }
        end
      end

      def downloading_unarchived_products
        @archive = false
        benchmarking(
          -> { "import: :mp_credential[#{@mp_credential.id}] — actual[#{@parsed_ids.size}] — Done" }
        ) { circle_downloader }
        @total = @parsed_ids.size
      end

      def circle_downloader
        page_tokens = {}
        loop do
          status, _, body = @http_client.call(
            params: LIMITS.merge(page_tokens),
            body: { archived: @archive }
          )
          if status == 200
            items = body&.dig(:result, :offerMappings) || []
            break if items.blank?

            import_payload(items)
          else # any other status anyway
            # To be safe, but we shouldn't get here.
            # This is possible if the status is < 400 and the status is != 200.
            raise MarketplaceAggregator::ApiError.new(
              status,
              I18n.t('errors.something_went_wrong'),
              mp_credential.id
            )
          end

          page_token = body&.dig(:result, :paging, :nextPageToken)
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
