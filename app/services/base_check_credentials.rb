# frozen_string_literal: true

# getting the status of the HTTP response
# calling the curl command or http_client
class BaseCheckCredentials
  def initialize(mp_credential)
    @mp_credential = mp_credential
  end

  def call
    curl = bash_command

    case message = curl.split("\r\n").first
    when %r{(HTTP/1.1 200)|(HTTP/2 200)}
      { ok: true }
    when %r{(HTTP/1.1 403)|(HTTP/2 403)|(HTTP/1.1 401)|(HTTP/2 401)|(<html>)}
      # find out details from e.message of POST request
      redo_post_request
    else
      { errors: message }
    end
  end

  private

  # curl command can invoke POST method with -I/--head option
  # https://curl.se/docs/manpage.html
  def bash_command
    raise NotImplementedError, "#{self.class}.#{__method__}: #{I18n.t('errors.marketplace_has_not_been_selected')}"
  end

  def http_client
    raise NotImplementedError, "#{self.class}.#{__method__}: #{I18n.t('errors.marketplace_has_not_been_selected')}"
  end

  def http_client_call
    @http_client.call
  end

  def redo_post_request
    @http_client = http_client
    http_client_call
    { ok: true }
  rescue MarketplaceAggregator::ApiError => e
    { errors: e.message || I18n.t('errors.something_went_wrong') }
  end
end
