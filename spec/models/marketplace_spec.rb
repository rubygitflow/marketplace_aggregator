# frozen_string_literal: true

require 'rails_helper'

module Yandex; class Bush; end; end

RSpec.describe Marketplace, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:clients).through(:marketplace_credentials) }
    it { is_expected.to have_many(:products).through(:marketplace_credentials) }
    it { is_expected.to have_many(:marketplace_credentials) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'methods' do
    let!(:marketplace_ozon) { create(:marketplace, :ozon) }
    let!(:marketplace_yandex) { create(:marketplace, :yandex) }
    let!(:marketplace_unknown) { create(:marketplace, :new) }

    it 'can return Marketplace.yandex' do
      expect(described_class.yandex).to be_truthy
    end

    it 'can return Marketplace.ozon' do
      expect(described_class.ozon).to be_truthy
    end

    it 'can check marketplace_yandex.yandex?' do
      expect(marketplace_yandex.yandex?).to be true
    end

    it 'can check marketplace_yandex.ozon?' do
      expect(marketplace_ozon.ozon?).to be true
    end

    it "can return Marketplace's code" do
      expect(marketplace_unknown.code).to eq('ton')
    end

    it 'can translate Marketplace title to extra class name' do
      expect(marketplace_yandex.to_constant_with(['Bush'])).to eq(Yandex::Bush)
    end

    it 'can convert Marketplace title to_symbol' do
      expect(marketplace_yandex.to_symbol).to eq(:yandex)
    end

    it 'can invoke Marketplace by its name' do
      expect(described_class.invoke('Yandex')).to be_truthy
    end

    it 'extract Marketplace Name by its Id' do
      expect(described_class.name_by_id(marketplace_ozon.id)).to eq(marketplace_ozon.name)
    end
  end
end
