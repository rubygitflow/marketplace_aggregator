# frozen_string_literal: true

module Handles
  module YandexProductStatus
    YANDEX_CARD_STATUS = {
      'PUBLISHED' => 'published',
      'CHECKING' => 'on_moderation',
      'DISABLED_BY_PARTNER' => 'unpublished',
      'DISABLED_AUTOMATICALLY' => 'unpublished',
      'REJECTED_BY_MARKET' => 'failed_moderation',
      'CREATING_CARD' => 'preliminary',
      'NO_CARD' => 'preliminary',
      'NO_STOCKS' => 'unpublished'
    }.freeze

    def take_yandex_card_status(offer)
      status = offer&.fetch(:campaigns, [])&.first&.fetch(:status, nil)
      YANDEX_CARD_STATUS.fetch(status, 'preliminary')
    end
  end
end
