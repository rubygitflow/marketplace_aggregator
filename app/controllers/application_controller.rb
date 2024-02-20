# frozen_string_literal: true

class ApplicationController < ActionController::API
  def current_user
    # @current_user ||= Client.find_by(id: session_user_uuid)
    @current_user ||= Client.find_by(id: http_user_uuid)
    # @current_user ||= Client.find_by(id: payload[:user_uuid])
    # @current_user ||= Client.find_by(id: env_user_uuid)
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
