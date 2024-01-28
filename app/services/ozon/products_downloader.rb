# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductList
# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoListV2
# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoDescription

module Ozon
  class ProductsDownloader
    attr_reader :mp_credential, :parsed_ids, :http_client_list, :http_client_info, :http_client_description

    def initialize(mp_credential)
      @mp_credential = mp_credential
      @http_client_list = Ozon::Api::ProductList.new(mp_credential)
      @http_client_info = Ozon::Api::ProductInfoList.new(mp_credential)
      @http_client_description = Ozon::Api::ProductInfoDescription.new(mp_credential)
      @parsed_ids = []
    end

    def call
      return false if mp_credential.credentials.nil?

      # download_products
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
