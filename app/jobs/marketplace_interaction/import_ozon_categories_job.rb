# frozen_string_literal: true

module MarketplaceInteraction
  class ImportOzonCategoriesJob < ApplicationJob
    include MaBenchmarking

    queue_as :default

    def perform
      mp_credential = MarketplaceCredential.ozon.valid.last
      benchmarking(-> { 'download: :ozon_categories — OK' }) { Ozon::LoadCategories.new(mp_credential).call }
    rescue StandardError => e
      ErrorLogger.push_trace e
    end
  end
end
