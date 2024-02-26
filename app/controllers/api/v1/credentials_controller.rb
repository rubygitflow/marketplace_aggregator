# frozen_string_literal: true

module Api
  module V1
    class CredentialsController < ApplicationController
      before_action :required_find_mp_credential, only: %i[update archive descriptions]

      def create
        mp_credential = credentials.new(credential_params)
        mp_credential.fix_credentials!
        Operations::CheckCredentials.new(mp_credential).call
        if mp_credential.is_valid
          mp_credential.save!
          Products::ImportJob.perform_later(true, mp_credential.id)
          render json: {
            marketplace_credential: mp_credential
          }
        else
          render json: {
            errors: [{
              code: 'error',
              title: I18n.t('errors.credentials_are_invalid'),
              detail: mp_credential.credentials['errors']
            }]
          }, status: 400
        end
      end

      def update
        resp, status = Tasks::ReimportProducts.new(true, @mp_credential, I18n.t('messages.users_control')).call
        render json: resp, status:
      end

      def archive
        value = Handles::ProductsDownloader.to_bool(params[:value])
        @mp_credential.autoload_archives.value = value if value.in? [true, false]
        render json: {
          marketplace_credential: {
            id: @mp_credential.id,
            autoload_archives: @mp_credential.autoload_archives.value
          }
        }
      end

      def descriptions
        value = Handles::ProductsDownloader.to_bool(params[:value])
        @mp_credential.autoload_descriptions.value = value if value.in? [true, false]
        render json: {
          marketplace_credential: {
            id: @mp_credential.id,
            autoload_descriptions: @mp_credential.autoload_descriptions.value
          }
        }
      end

      private

      def required_find_mp_credential
        @mp_credential = current_user.marketplace_credentials.find_by(id: params[:id])
        if @mp_credential.nil?
          render json: {
            errors: [{
              code: 'error',
              title: I18n.t('errors.not_found', class_name: 'MarketplaceCredential')
            }]
          }, status: 404
        end
      end

      def credentials
        @credentials ||= current_user.marketplace_credentials
      end

      def credential_params
        params.permit(:instance_name, credentials: {}).merge(
          marketplace: marketplace(params[:marketplace])
        )
      end
    end
  end
end
