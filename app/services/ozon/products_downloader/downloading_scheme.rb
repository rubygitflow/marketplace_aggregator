# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductList

module Ozon
  class ProductsDownloader
    module DownloadingScheme
      include Ozon::ProductsDownloader::LoadingInfoList
      include Ozon::ProductsDownloader::ImportDesriptions
      include MaBenchmarking

      PAGE_LIMIT = 1000

      def download_products
        # 1. download products not from the archive
        downloading_unarchived_products
        # 2. download products from the archive
        downloading_archived_products
        # 3. download product desriptions
        downloading_desriptions
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

      def downloading_desriptions
        if @mp_credential.autoload_descriptions.value
          benchmarking(
            -> { "import: :mp_credential[#{@mp_credential.id}] — desriptions[#{@parsed_ids.size}] — Done" }
          ) { downloading_product_desriptions }
        end
      end

      def circle_downloader
        page_tokens = {}
        loop do
          status, _, body = @http_client_list.call(
            body: {
              filter: {
                visibility: (@archive ? 'ARCHIVED' : 'ALL')
              },
              limit: PAGE_LIMIT
            }.merge(page_tokens)
          )
          break_if_http_error(status) if status != 200

          items = (body&.dig(:result, :items) || []).map { |elem| elem[:product_id] }
          break if items.blank?

          download_product_info_list(items)

          page_token = body&.dig(:result, :last_id)
          if page_token.blank?
            break
          else
            page_tokens = { last_id: page_token }
          end
        end
      end

      def break_if_http_error(status)
        # To be safe, but we shouldn't get here.
        # This is possible if the status is < 400 and the status is != 200.
        raise MarketplaceAggregator::ApiError.new(
          status,
          I18n.t('errors.downloading_the_product_list'),
          mp_credential.id
        )
      end

      private :downloading_archived_products, :downloading_unarchived_products, :circle_downloader,
              :break_if_http_error
    end
  end
end
