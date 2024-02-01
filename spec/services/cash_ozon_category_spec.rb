# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CashOzonCategory, type: :service do
  let!(:category1) { create(:ozon_category, :с_15621048_91258) }
  let!(:category2) { create(:ozon_category, :с_15621032_0) }
  # let!(:obj) { described_class }

  before do
    described_class.clear
  end

  after do
    described_class.clear
  end

  it 'takes an existing category' do
    expect(described_class.o_cat.to_h.size).to eq 0
    expect(described_class.get(15621048, 91258)).to eq 'Обувь/Повседневная обувь/Полусапоги'
    expect(described_class.get(15621032, 0)).to eq 'Обувь/'
    expect(described_class.o_cat.to_h.size).to eq 2
  end

  it 'returns the nil value for a non-existent category' do
    expect(described_class.o_cat.to_h.size).to eq 0
    expect(described_class.get(15621048, 91)).to eq nil
    expect(described_class.o_cat.to_h.size).to eq 0
  end

  it 'can clear the cash' do
    expect(described_class.o_cat.to_h.size).to eq 0
    expect(described_class.get(15621048, 91258)).to eq 'Обувь/Повседневная обувь/Полусапоги'
    expect(described_class.o_cat.to_h.size).to eq 1
    expect(described_class.o_cat.to_h).to eq({ '15621048_91258' => 'Обувь/Повседневная обувь/Полусапоги' })
    described_class.clear
    expect(described_class.o_cat.to_h.size).to eq 0
  end
end
