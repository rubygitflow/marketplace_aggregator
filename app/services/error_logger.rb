# frozen_string_literal: true

class ErrorLogger
  class << self
    def push(e, ext_message: nil)
      msg = "#{e.class}: #{e.message}"
      msg << '; ' << ext_message unless ext_message.nil?
      Rails.logger.error msg
    end

    def push_trace(e)
      Rails.logger.error e.backtrace[1, 5].join("\n")
    end
  end
end
