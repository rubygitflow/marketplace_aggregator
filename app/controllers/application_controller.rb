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

    @current_user ||= Client.find_by(id: http_user_uuid)
    raise MarketplaceAggregator::ForbiddenError unless @current_user

    @current_user
  end

  def marketplace(attr)
    @marketplace ||= Marketplace.find_by_name(attr.capitalize) ||
                     Marketplace.find_by_label(attr)
  end

  private

  def http_user_uuid
    request.headers['HTTP_USER']
  end
end
