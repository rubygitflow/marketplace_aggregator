# frozen_string_literal: true

class ChangeOzonCategoriesTypeDisabled < ActiveRecord::Migration[7.1]
  def change
    change_column_null :ozon_categories, :type_disabled, false
  end
end
