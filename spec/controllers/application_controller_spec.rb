# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let!(:template) { described_class.new }

  describe 'GET marketplace as Ozon' do
    let!(:marketplace_ozon) { create(:marketplace, :ozon) }

    it 'returns the marketplace by the marketplace name' do
      expect(template.marketplace('OZON').id).to eq marketplace_ozon.id
    end
  end

  describe 'GET marketplace as Yandex.Market' do
    let!(:marketplace_yandex) { create(:marketplace, :yandex) }

    it 'returns the marketplace by the marketplace label' do
      expect(template.marketplace('Яндекс.Маркет').id).to eq marketplace_yandex.id
    end
  end
end
