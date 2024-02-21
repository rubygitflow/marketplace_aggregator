# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operations::DownloadDescriptions, type: :business_logic do
  let!(:marketplace_credential) { create(:marketplace_credential, :ozon) }
  let!(:operation) { described_class.new(marketplace_credential) }

  context 'with #ozon_allowed? (inversion to the autoload_descriptions value)' do
    before do
      marketplace_credential.autoload_descriptions.value = false
    end

    it 'is true' do
      expect(operation.send('ozon_allowed?')).to eq true
    end
  end

  context 'with not #ozon_allowed? (inversion to the  autoload_descriptions value)' do
    before do
      marketplace_credential.autoload_descriptions.value = true
    end

    it 'is false' do
      expect(operation.send('ozon_allowed?')).to eq false
    end
  end
end
