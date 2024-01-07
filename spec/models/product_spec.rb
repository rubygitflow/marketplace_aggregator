# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Product, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:marketplace_credential) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'initial scrub_status' do
    let(:product) { create(:product, :yandex) }

    it { expect(product.status).to eq('preliminary') }
  end

  describe 'initial status' do
    let(:product) { create(:product, :ozon) }

    it { expect(product.scrub_status).to eq('unspecified') }
  end

  describe 'added values' do
    let!(:product) { create(:product, :yandex, offer_id: '321') }
    let(:currency) { 'RUR' }
    let(:price) { '20.0000' }
    let(:selling_program_1) { 'fbs' }
    let(:selling_program_2) { 'fb0' }

    it 'gets monetary_amount type of price' do
      prod = described_class.find_or_initialize_by(offer_id: '321')
      prod.price = "(#{price},#{currency})"
      prod.save!
      expect(described_class.find(prod.id).price).to eq('(20,RUR)')
    end

    it 'gets selling_program to scheme' do
      prod = described_class.find_or_initialize_by(offer_id: '321')
      prod.schemes = [selling_program_1] << selling_program_2
      prod.save!
      expect(described_class.find(prod.id).schemes).to eq(%w[fbs fb0])
    end
  end
end
