# frozen_string_literal: true

module BusinessLogic
  module Handles
    class ProductsDownloader
      CARD_STATUS = {
        'PUBLISHED' => 'published',
        'CHECKING' => 'on_moderation',
        'DISABLED_BY_PARTNER' => 'unpublished',
        'DISABLED_AUTOMATICALLY' => 'unpublished',
        'REJECTED_BY_MARKET' => 'failed_moderation',
        'CREATING_CARD' => 'preliminary',
        'NO_CARD' => 'preliminary',
        'NO_STOCKS' => 'unpublished'
      }.freeze

      class << self
        def from_archive
          ENV.fetch('PRODUCTS_DOWNLOADER_FROM_ARCHIVE') || false
        end

        def take_card_status(offer)
          status = offer&.fetch(:campaigns, [])&.first&.fetch(:status, nil)
          CARD_STATUS.fetch(status, 'preliminary')
        end
      end
    end
  end
end
