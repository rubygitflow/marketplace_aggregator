# frozen_string_literal: true

# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings

module Yandex
  class ProductsDownloader
    include Yandex::ProductsDownloader::DownloadingScheme

    attr_reader :mp_credential, :http_client, :parsed_ids

    def initialize(mp_credential)
      @mp_credential = mp_credential
      @http_client = Yandex::Api::OfferMappings.new(mp_credential)
      @parsed_ids = []
    end

    def call
      return false if mp_credential.credentials.nil?

      download_products
      tag_lost_products!
      true
    end

    private

    def tag_lost_products!
      products = Product.where(marketplace_credential_id: mp_credential.id)
      lost_offer_ids = products.pluck(:offer_id) - parsed_ids

      products.where(
        offer_id: lost_offer_ids
      ).update_all(scrub_status: 'gone')
    end
  end
end
