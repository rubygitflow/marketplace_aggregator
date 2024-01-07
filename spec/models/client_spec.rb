# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Client, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:marketplaces).through(:marketplace_credentials) }
    it { is_expected.to have_many(:products).through(:marketplace_credentials) }
    it { is_expected.to have_many(:marketplace_credentials).dependent(:destroy) }
  end

  describe 'methods' do
    let!(:client) { create(:client) }
    let!(:marketplace_yandex) { create(:marketplace, :yandex) }
    let!(:marketplace_ozon) { create(:marketplace, :ozon) }
    let!(:client_yandex_credentials) do
      create(:marketplace_credential, :yandex,
             client:,
             marketplace: marketplace_yandex,
             credentials: { 'shipment_types' => 'fbs',
               'instance_name' => 'dmsS24',
               'campaign_id' => '22201602',
               'token' => 'AQAAA4ulzBSUbpYJzFk',
               'errors' => nil })
    end
    let!(:client_ozon_credentials) do
      create(:marketplace_credential, :ozon, client:,
      marketplace: marketplace_ozon)
    end

    it 'is callable credentials(marketplace)' do
      expect(client.credentials(marketplace_yandex)).to eq(client_yandex_credentials[:credentials])
      expect(client.credentials(marketplace_ozon)).to eq(client_ozon_credentials[:credentials])
    end
  end
end
