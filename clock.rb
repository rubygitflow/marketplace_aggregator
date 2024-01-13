# frozen_string_literal: true

require 'clockwork'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)

module Clockwork
  every(1.day, 'Import products', at: '23:00') do
    MarketplaceInteraction::ImportProductsJob.perform_later
  end
end
