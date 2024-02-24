# frozen_string_literal: true

# https://docs.ozon.ru/api/seller/#operation/ProductAPI_GetProductInfoDescription

module Ozon
  class ProductDescriptionsDownloader
    include Ozon::ProductsDownloader::ImportDesriptions
    include MaBenchmarking

    attr_reader :mp_credential, :parsed_ids, :http_client_description

    def initialize(mp_credential)
      @mp_credential = mp_credential
      @http_client_description = Ozon::Api::ProductInfoDescription.new(mp_credential)
      @parsed_ids = {}
    end

    def call
      return false if mp_credential.credentials.nil?

      # 1. download products not from the archive
      downloading_unarchived_product_desriptions
      # 2. download products from the archive
      downloading_archived_product_desriptions

      true
    end

    private

    def downloading_archived_product_desriptions
      if @mp_credential.autoload_archives.value
        @parsed_ids = Product.where(marketplace_credential_id: mp_credential.id,
                                    scrub_status: 'success',
                                    status: 'archived')
                             .pluck(:product_id, 0).to_h
        benchmarking(
          -> { "import Desriptions: :mp_credential[#{@mp_credential.id}] — archived[#{@parsed_ids.size}] — Done" }
        ) { downloading_product_desriptions }
      end
    end

    def downloading_unarchived_product_desriptions
      @parsed_ids = Product.where(marketplace_credential_id: mp_credential.id,
                                  scrub_status: 'success')
                           .where.not(status: 'archived')
                           .pluck(:product_id, 0).to_h
      benchmarking(
        -> { "import Desriptions: :mp_credential[#{@mp_credential.id}] — actual[#{@parsed_ids.size}] — Done" }
      ) { downloading_product_desriptions }
    end
  end
end
