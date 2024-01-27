# frozen_string_literal: true

class ChangeOzonCategoriesCategoryDisabled < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ozon_categories, :category_disabled, false
  end
end
