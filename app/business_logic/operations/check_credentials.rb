# frozen_string_literal: true

module Operations
  class CheckCredentials
    CHECKER_CLASS = 'CheckCredentials'

    def initialize(mp_credential)
      @mp_credential = mp_credential
    end

    def call
      # 1. Verify marketplace_credential.credentials != nil
      if @mp_credential.credentials.nil?
        @result_valid = { errors: 'empty credentials' }
        @mp_credential.credentials = {}
      end
      do_check_credentials if @result_valid.nil?
      # 5. Update @mp_credential
      set_credentials_valid
    end

    private

    def do_check_credentials
      # 2. Define the class to be called
      @result_valid = process(@mp_credential.marketplace.to_constant_with(CHECKER_CLASS).new(@mp_credential))
      # 4. Notify client if needed
      notify_client unless @result_valid[:ok]
    rescue StandardError => e
      ErrorLogger.push_trace e
      @result_valid = { errors: e.message }
    end

    def set_credentials_valid
      @mp_credential.is_valid = @result_valid[:ok] || false
      @mp_credential.credentials = if @mp_credential.is_valid
                                     @mp_credential.credentials.delete_if { |key, _value| key == 'errors' }
                                   else
                                     @mp_credential.credentials.merge(@result_valid)
                                   end
    end

    def process(checker)
      # 3. Make a HEAD HTTP request
      checker.call
    end

    def notify_client
      # TODO: To call some kind of task with a notification
    end
  end
end
