# frozen_string_literal: true

namespace :ozon_categories do
  desc 'Seeds ozon categories'
  task load: :environment do
    mp_credential = MarketplaceCredential.ozon.valid.last
    Ozon::LoadCategories.new(mp_credential).call
    # TODO: To send a report on the successful update of the list of categories
    Rails.logger.info 'load: :ozon_categories — OK'
  rescue StandardError => e
    ErrorLogger.push_trace e
  end
end
