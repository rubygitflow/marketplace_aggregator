# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarketplaceCredential, type: :model do
  describe 'scopes' do
    let!(:marketplace_credential) { create(:marketplace_credential, is_valid: true) }
    let!(:marketplace_credential_not_authentic) { create(:marketplace_credential, :not_authentic) }
    let!(:marketplace_credential_not_valid) { create(:marketplace_credential, is_valid: false) }

    it 'is authentic' do
      expect(described_class.authentic.size).to eq(2)
    end

    it 'is valid' do
      expect(described_class.valid.length).to eq(1)
    end

    it 'is invalid' do
      expect(described_class.invalid.length).to eq(2)
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:client) }
    it { is_expected.to belong_to(:marketplace) }
    it { is_expected.to have_many(:products).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :instance_name }
  end

  describe 'methods' do
    let!(:client) { create(:client) }
    let!(:marketplace_yandex) { create(:marketplace, :yandex) }

    it 'fix_credentials! for Yandex by compaghn_id' do
      mp_cred_1 = create(:marketplace_credential, :yandex, client:,
        marketplace: marketplace_yandex,
        credentials: {
          'business_id' => '11-22202834 ID \\u043C\\u0430\\u0433\\u0430\\u0437\\u0438\\u043D\\u0430',
          'token' => 'AQAAAABWGnM4AAZ7wIY4ulzBSUdlqwjubpYJzFk'
        }).fix_credentials!
      expect(mp_cred_1['business_id']).to eq('22202834')

      mp_cred_2 = create(:marketplace_credential, :yandex, client:,
        marketplace: marketplace_yandex,
        credentials: {
          'business_id' => "11-21968409 \t",
          'token' => 'AQAAAABWGnM4AAZ7wIY4ulzBSUdlqwjubpYJzFk'
        }).fix_credentials!
      expect(mp_cred_2['business_id']).to eq('21968409')

      mp_cred_3 = create(:marketplace_credential, :yandex, client:,
        marketplace: marketplace_yandex,
        credentials: {
          'business_id' => '11-22201602',
          'token' => 'AQAAAABWGnM4AAZ7wIY4ulzBSUdlqwjubpYJzFk'
        }).fix_credentials!
      expect(mp_cred_3['business_id']).to eq('22201602')
    end
  end
end
