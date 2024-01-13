# frozen_string_literal: true

module Products
  class ImportJob < ApplicationJob
    queue_as do
      is_client_queue = arguments.first
      if is_client_queue
        :client_grabber_products
      else
        :marketplace_grabber_products
      end
    end

    DOWNLOADER_CLASS = 'ProductsDownloader'

    def perform(is_client_queue, mp_credential_id)
      @mp_credential = MarketplaceCredential.find_by(id: mp_credential_id)
      return if @mp_credential.blank? || @mp_credential.deleted_at

      @mp_credential.update(last_sync_at_products: Time.current) if downloadable?
    end

    private

    def downloadable?
      downloader = @mp_credential.marketplace.to_constant_with(DOWNLOADER_CLASS)
      downloader.new(@mp_credential).call
    rescue NameError => e
      Rails.logger.error "#{e.class}: #{e.message}"
      Rails.logger.error e.backtrace[1, 5].join("\n")
      false
    end
  end
end
