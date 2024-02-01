# frozen_string_literal: true

require 'rails_helper'

RSpec.describe OzonCategory, type: :model do
  describe 'default values' do
    let(:category) { described_class.new }

    it 'does not have null values in\
    description_category_id, type_id, category_disabled, type_disabled\
    for new record' do
      expect(category.description_category_id).to eq 0
      expect(category.type_id).to eq 0
      expect(category.category_disabled).to be false
      expect(category.type_disabled).to be false
    end
  end
end
