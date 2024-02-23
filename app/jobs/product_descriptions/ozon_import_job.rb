# frozen_string_literal: true

module ProductDescriptions
  class OzonImportJob < ApplicationJob
    queue_as do
      is_client_queue = arguments.first
      if is_client_queue
        :client_grabber_product_descriptions
      else
        :marketplace_grabber_product_descriptions
      end
    end

    DOWNLOADER_CLASS = 'ProductDescriptionsDownloader'

    def perform(is_client_queue, mp_credential_id)
      @is_client_queue = is_client_queue
      @mp_credential = MarketplaceCredential.find_by(id: mp_credential_id)
      return if irrelevant?

      import(@mp_credential.marketplace.to_constant_with(DOWNLOADER_CLASS).new(@mp_credential))
    end

    private

    def irrelevant?
      @mp_credential.blank? ||
        @mp_credential.credentials.blank? ||
        @mp_credential.deleted_at
    end

    def import(downloader)
      back_time = Time.now
      downloader.call
      Rails.logger.info log(downloader.parsed_ids.size, back_time).strip
    end

    def log(count, back_time)
      <<~MESSAGE
        import: :mp_credential[#{@mp_credential.id}] — \
        Ozon Product Descriptions: #{count} - \
        OK (in #{(Time.now - back_time).round(3)} sec)
      MESSAGE
    end
  end
end
