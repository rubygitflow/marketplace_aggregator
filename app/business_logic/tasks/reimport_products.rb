# frozen_string_literal: true

# https://yandex.ru/dev/market/partner-api/doc/ru/reference/business-assortment/getOfferMappings
# Limit: 600 requests per minute

module Tasks
  class ReimportProducts
    def initialize(is_client_queue, mp_credential, e)
      @is_client_queue = is_client_queue
      @mp_credential = mp_credential
      @error = e
    end

    def call
      # 1. check the history of ReimportProducts calls
      # It should be less than three times
      reimportable? do
        # 2. cause direct data import
        Products::ImportJob.set(wait_until: 1.minute.from_now)
                           .perform_later(@is_client_queue, @mp_credential.id)
      end
    end

    private

    def reimportable?
      if @mp_credential.reimport_products.exceeded?
        ErrorLogger.push(
          @error,
          ext_message: I18n.t('errors.try_restart_after_an_hour',
                              task_name: self.class.name)
        )
      else
        @mp_credential.reimport_products.poke
        ErrorLogger.push(
          @error,
          ext_message: "№#{@mp_credential.reimport_products.value}"
        )
        yield
      end
    end
  end
end
