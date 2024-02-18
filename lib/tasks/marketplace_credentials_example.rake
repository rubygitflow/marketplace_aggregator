# frozen_string_literal: true

# To get any unique UUID
# type in terminal
# $ irb
# irb(main):001> require 'securerandom'
# irb(main):002> SecureRandom.uuid
#
# or get it from
# https://www.uuidgenerator.net

namespace :marketplace_credentials_example do
  desc 'Seeds marketplace credentials'
  task custom_seeds: :environment do
    # The first client
    user = Client.find_or_create_by!(id: '4cbd4328-6a81-4f3d-bed1-a9761241b0a2')

    # Yandex.Market credentials
    MarketplaceCredential.find_or_create_by(id: 'b0f2cf0e-b4aa-4448-9a58-1d9715c6079f') do |mc|
      mc.client_id = user.id
      mc.marketplace_id = Marketplace.yandex.id
      mc.instance_name = 'any_client_login_to_the_app'
      mc.credentials = {
        token: 'client_oauth_token_from_yandex_marketplace',
        business_id: 'client_businessId_from_yandex_marketplace'
      }
    end

    # OZON credentials
    MarketplaceCredential.find_or_create_by(id: 'f1bbfa0d-abf3-464f-b2a9-815b07a0cf52') do |mc|
      mc.client_id = user.id
      mc.marketplace_id = Marketplace.ozon.id
      mc.instance_name = 'any_client_login_to_the_app'
      mc.credentials = {
        api_key: 'client_API-KEY_from_ozon_marketplace',
        client_id: 'Client-ID_from_ozon_marketplace'
      }
    end

    # The second client
    user = Client.find_or_create_by!(id: '1fbc260d-4669-480d-8c42-659f12b07941')

    # OZON credentials
    MarketplaceCredential.find_or_create_by(id: 'e364829e-4b76-484c-b39c-77ca8b058085') do |mc|
      mc.client_id = user.id
      mc.marketplace_id = Marketplace.ozon.id
      mc.instance_name = 'any_client_login_to_the_app'
      mc.credentials = {
        api_key: 'client_API-KEY_from_ozon_marketplace',
        client_id: 'Client-ID_from_ozon_marketplace'
      }
    end

    # and so on
  end
end
