# frozen_string_literal: true

module Tasks
  class ImportProductDescriptions
    def call
      MarketplaceCredential.find_each(batch_size: 100) do |mp_credential|
        Operations::DownloadDescriptions.new(mp_credential).call
      end
    end
  end
end
