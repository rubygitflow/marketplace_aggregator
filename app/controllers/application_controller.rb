# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from(MarketplaceAggregator::UnauthorizedError) do
    render json: {
      errors: [{
        code: 'error',
        title: I18n.t('errors.unauthorized')
      }]
    }, status: :unauthorized
  end

  rescue_from(MarketplaceAggregator::ForbiddenError) do
    render json: {
      errors: [{
        code: 'error',
        title: I18n.t('errors.forbidden')
      }]
    }, status: :forbidden
  end

  def current_user
    raise MarketplaceAggregator::UnauthorizedError unless fetch_user_uuid

    @current_user ||= Client.find_by(id: fetch_user_uuid)
    raise MarketplaceAggregator::ForbiddenError unless @current_user

    @current_user
  end

  def marketplace(attr)
    @marketplace = Marketplace.find_by(name: attr.capitalize) ||
                   Marketplace.find_by(label: attr)
  end

  private

  def fetch_user_uuid
    request.headers['HTTP_USER']
  end
end
