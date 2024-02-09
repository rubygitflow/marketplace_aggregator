# frozen_string_literal: true

module MarketplaceInteraction
  class ImportProductDescriptionsJob < ApplicationJob
    queue_as :marketplace_grabber_products

    def perform
      Tasks::ImportProductDescriptions.new.call
    end
  end
end
