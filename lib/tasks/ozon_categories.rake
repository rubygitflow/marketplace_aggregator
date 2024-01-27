# frozen_string_literal: true

namespace :ozon_categories do
  desc 'Seeds ozon categories'
  task load: :environment do
    MarketplaceInteraction::ImportOzonCategoriesJob.perform_later
  end
end
