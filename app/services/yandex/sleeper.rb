# frozen_string_literal: true

module Yandex
  module Sleeper
    LIMITING_REMAINING_REQUESTS = 5

    # INPUT:
    # headers = {
    #   Date: Tue, 09 Jan 2024 09:14:10 GMT
    #   X-RateLimit-Resource-Until: Tue, 09 Jan 2024 09:15:00 GMT
    # }
    def do_sleep(headers, duration)
      dt =
        Time.parse(headers['X-RateLimit-Resource-Until']) -
        Time.parse(headers['Date']) +
        1
      if dt > duration
        Rails.logger.error I18n.t('errors.duration_of_rate_limit_has_been_changed',
                                  marketplace_name: 'Yandex')
      else
        sleep dt
      end
    rescue StandardError => e
      # We are checking the code. It's fixable
      ErrorLogger.push_trace e
    end

    def limiting_remaining_requests
      ENV.fetch('LIMITING_REMAINING_REQUESTS', LIMITING_REMAINING_REQUESTS)
         .to_i
    end

    private :do_sleep, :limiting_remaining_requests
  end
end
