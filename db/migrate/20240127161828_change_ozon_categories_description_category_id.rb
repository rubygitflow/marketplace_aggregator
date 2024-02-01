# frozen_string_literal: true

class ChangeOzonCategoriesDescriptionCategoryId < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ozon_categories, :description_category_id, false
    change_column_default :ozon_categories, :description_category_id, from: nil, to: 0
  end
end
