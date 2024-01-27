# frozen_string_literal: true

module MarketplaceInteraction
  class ImportOzonCategoriesJob < ApplicationJob
    queue_as :default

    def perform
      mp_credential = MarketplaceCredential.ozon.valid.last
      Ozon::LoadCategories.new(mp_credential).call
      # TODO: To send a report on the successful update of the list of categories
      Rails.logger.info 'download: :ozon_categories — OK'
    rescue StandardError => e
      ErrorLogger.push_trace e
    end
  end
end
