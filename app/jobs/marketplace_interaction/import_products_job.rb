# frozen_string_literal: true

require './app/business_logic/tasks/import_products'

module MarketplaceInteraction
  class ImportProductsJob < ApplicationJob
    queue_as :marketplace_grabber_products

    def perform
      BusinessLogic::Tasks::ImportProducts.new.call
    end
  end
end
