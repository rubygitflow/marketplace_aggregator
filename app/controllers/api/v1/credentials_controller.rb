# frozen_string_literal: true

module Api
  module V1
    class CredentialsController < ApplicationController
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

      private

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