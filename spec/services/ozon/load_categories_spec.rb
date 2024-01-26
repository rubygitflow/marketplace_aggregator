# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ozon::LoadCategories, type: :service do
  describe 'successful downloading of categories' do
    include_context 'with marketplace_credential ozon description-category/tree'

    before do
      described_class.new(marketplace_credential).call
    end

    it 'gains new records with the categories on the marketplace' do
      expect(OzonCategory.count).to eq 15
    end

    # rubocop:disable Style/NumericLiterals
    it 'imports category description' do
      category = OzonCategory.find_by(
        description_category_id: 17028974,
        type_id: 92886
      )
      expect(category.category_name).to eq 'Детские товары/Обучающие игры'
      expect(category.category_disabled).to be false
      expect(category.type_name).to eq 'Диапроектор'
      expect(category.type_disabled).to be false
    end
    # rubocop:enable Style/NumericLiterals
  end
end
