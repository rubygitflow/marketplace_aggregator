# frozen_string_literal: true

# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings

module Yandex
  class ProductsDownloader
    PAGE_LIMIT = 200

    attr_reader :mp_credential, :http_client, :parsed_ids, :page_token

    def initialize(mp_credential)
      @mp_credential = mp_credential
      @http_client = Yandex::Api::OfferMappings.new(mp_credential)
      @page_token = nil
      @parsed_ids = []
    end

    def call
      return false if mp_credential.credentials.nil?

      call_market_api
      mark_deleted_products!
      true
    end

    private

    def call_market_api; end

    def mark_deleted_products!
      products = Product.where(marketplace_credential_id: mp_credential.id)
      offer_ids = products.pluck(:offer_id) - parsed_ids

      products.where(
        offer_id: offer_ids
      ).update_all(scrub_status: 'gone')
    end
  end
end
