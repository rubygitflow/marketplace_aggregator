# frozen_string_literal: true

module Operations
  class DownloadDescriptions
    def initialize(mp_credential)
      @mp_credential = mp_credential
    end

    def call(force: false)
      ProductDescriptions::OzonImportJob.perform_later(force, @mp_credential.id) if ozon_allowed?
    end

    private

    def ozon_allowed?
      @mp_credential.marketplace.ozon? &&
        Handles::ProductsDownloader.ozon_descriptions?(self.class)
    end
  end
end
