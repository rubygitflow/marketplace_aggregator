# frozen_string_literal: true

require 'rails_helper'
require './app/business_logic/tasks/import_products'

RSpec.describe BusinessLogic::Tasks::ImportProducts, type: :business_logic do
  context 'with valid credentials after invalid credentials' do
    let!(:marketplace_credential) { create(:marketplace_credential, :yandex) }
    let!(:task) { described_class.new }
    let(:updated_credentials) do
      {
        'business_id' => '12345',
        'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87',
        'errors' => 'Token is invalid (Error parsing token: malformed embedded info)'
      }
    end
    let(:reupdated_credentials) do
      {
        'business_id' => '12345',
        'token' => 'y0_LgAYURBVC257AAZ7wigosAD2JlN9_WFVEK2W60anWh0lI8JMMIHWe87'
      }
    end

    it "can remove CheckCredentials' errors from marketplace_credential.credentials field" do
      task.call
      expect(MarketplaceCredential.find(marketplace_credential.id).credentials).to eq(updated_credentials)

      uri_template = Addressable::Template.new(
        "https://api.partner.market.yandex.ru/businesses/#{marketplace_credential.credentials.[]('business_id')}/offer-mappings.json{?limit}"
      )
      stub_request(:any, uri_template)
        .with(
          {
            headers: {
              'Authorization' => "OAuth oauth_token=\"#{marketplace_credential.credentials.[]('token')}\", oauth_client_id=\"#{ENV.fetch('YANDEX_APP_ID')}\"",
              'Content-Type' => 'application/json'
            }
          }
        )
        .to_return(
          body: '{}',
          status: 200,
          headers: { 'Content-Type' => 'application/json;charset=utf-8' }
        )
      task.call
      expect(MarketplaceCredential.find(marketplace_credential.id).credentials).to eq(reupdated_credentials)
    end
  end
end
