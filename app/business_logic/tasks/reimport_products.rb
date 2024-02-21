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
      analyse do
        # 2. cause direct data import
        Products::ImportJob.set(wait_until: 1.minute.from_now)
                           .perform_later(@is_client_queue, @mp_credential.id)
      end
    end

    private

    def analyse
      if @mp_credential.reimport_products.exceeded?
        notify_too_many_requests if @error.is_a?(Exception)
        [{ errors: [{
          code: 'error',
          title: I18n.t('errors.too_many_requests'),
          detail: I18n.t('errors.repeat_after_an_hour')
        }] }, 429]
      else
        @mp_credential.reimport_products.poke
        notify_last_error_to_reimport if @error.is_a?(Exception)
        yield
        [{ messages: [{
          code: 'message',
          title: I18n.t('messages.process_has_started'),
          detail: I18n.t('messages.check_in_ten_minutes')
        }] }, 200]
      end
    end

    def notify_too_many_requests
      ErrorLogger.push(
        @error,
        ext_message: I18n.t('errors.try_restart_after_an_hour',
                            task_name: self.class.name)
      )
    end

    def notify_last_error_to_reimport
      ErrorLogger.push(
        @error,
        ext_message: "№#{@mp_credential.reimport_products.value}"
      )
    end
  end
end
