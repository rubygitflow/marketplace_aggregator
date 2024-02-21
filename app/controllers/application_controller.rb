# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from(ActionController::InvalidAuthenticityToken) do
    render json: {
      errors: [{
        code: 'error',
        title: I18n.t('errors.unauthorized')
      }]
    }, status: 401
  end

  rescue_from(MarketplaceAggregator::ForbiddenError) do
    render json: {
      errors: [{
        code: 'error',
        title: I18n.t('errors.forbidden')
      }]
    }, status: 403
  end

  def current_user
    raise ActionController::InvalidAuthenticityToken unless http_user_uuid

    # @current_user ||= Client.find_by(id: session_user_uuid)
    @current_user ||= Client.find_by(id: http_user_uuid)
    # @current_user ||= Client.find_by(id: payload[:user_uuid])
    # @current_user ||= Client.find_by(id: env_user_uuid)
    raise MarketplaceAggregator::ForbiddenError unless @current_user

    @current_user
  end

  def marketplace(attr)
    @marketplace ||= Marketplace.find_by_name(attr.capitalize) ||
                     Marketplace.find_by_label(attr)
  end

  private

  # def env_user_uuid
  #   ENV['USER_UUID']
  # end

  # def session_user_uuid
  #   session['user_uuid']
  # end

  def http_user_uuid
    request.headers['HTTP_USER']
  end

  # def payload
  #   payload_header[0].deep_symbolize_keys
  # end

  # def payload_header
  #   JWT.decode(token,
  #              Settings.jwt.secret_key,
  #              true,
  #              { algorithm: 'HS256' })
  # rescue JWT::ExpiredSignature
  #   not_authorized
  # end

  # def not_authorized
  #   render(json: { error: 'Not Authorized' }, status: :unauthorized)
  # end
end
