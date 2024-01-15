# frozen_string_literal: true

module MarketplaceInteraction
  class ImportProductsJob < ApplicationJob
    queue_as :marketplace_grabber_products

    def perform
      Tasks::ImportProducts.new.call
    end
  end
end
