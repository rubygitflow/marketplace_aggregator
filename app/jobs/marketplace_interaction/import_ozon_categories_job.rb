# frozen_string_literal: true

module MarketplaceInteraction
  class ImportOzonCategoriesJob < ApplicationJob
    queue_as :default

    def perform
      mp_credential = MarketplaceCredential.ozon.valid.last
      back_time = Time.now
      Ozon::LoadCategories.new(mp_credential).call

      # TODO: To send a report on the successful update of the list of categories
      Rails.logger.info "download: :ozon_categories — OK (in #{(Time.now - back_time).round(3)} sec)"
    rescue StandardError => e
      ErrorLogger.push_trace e
    end
  end
end
