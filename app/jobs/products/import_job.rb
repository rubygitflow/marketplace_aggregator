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
      @is_client_queue = is_client_queue
      @mp_credential = MarketplaceCredential.find_by(id: mp_credential_id)
      return if irrelevant?

      @mp_credential.update(last_sync_at_products: Time.current) if downloadable?
    end

    private

    def irrelevant?
      @mp_credential.blank? ||
        @mp_credential.credentials.blank? ||
        @mp_credential.deleted_at
    end

    def downloadable?
      import
      true
    rescue NameError => e
      # We are checking the code. It's fixable
      ErrorLogger.push_trace e
      false
    rescue MarketplaceAggregator::ApiAccessDeniedError => e
      ErrorLogger.push e
      # that's all
      false
    rescue MarketplaceAggregator::ApiBadRequestError => e
      ErrorLogger.push e
      # that's all
      false
    rescue MarketplaceAggregator::ApiLimitError => e
      # restart the task taking into account restrictions on limits
      Tasks::ReimportProducts.new(@is_client_queue, @mp_credential, e).call
      false
    rescue MarketplaceAggregator::ApiError => e
      ErrorLogger.push e
      # TODO: restart task after an hour (for example)
      false
    end

    def import
      downloader = @mp_credential.marketplace.to_constant_with(DOWNLOADER_CLASS)
                                 .new(@mp_credential)
      back_time = Time.now
      downloader.call
      Rails.logger.info log(downloader.parsed_ids.size, back_time).strip
    end

    def log(count, back_time)
      <<~MESSAGE
        import: :mp_credential[#{@mp_credential.id}] — \
        [#{count}] - \
        OK (in #{(Time.now - back_time).round(3)} sec)
      MESSAGE
    end
  end
end
